defmodule ApmIssues.Repo do
  require Logger
  use GenServer

  @moduledoc"""
  The _Repository_ for _Issues_ is a simple `GenServer` to store, update, and
  delete `ApmIssues.Issue` in the `ApmRepository.Bucket`("issues"). 
  This `GenServer` itself holds just the PID of the named `Bucket`.
  """

  @doc"""
    Start the Repo with the given name ('issues' by default)
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: __MODULE__)
  end

  @doc"""
    Start the `ApmRepository.Bucket` with the given name and the `type`
    `ApmIssues.Issue` for its entries.

    If environment is not 'production', the repository gets seeded from
    a JSON-File from `data/fixtures/issues.json`
  """
  def init(name) do
    Logger.info "Start Repo #{inspect name}"
    {:ok, _t, bucket} = ApmRepository.new_bucket({name, ApmIssues.Issue})
    unless Mix.env() == :test, do: ApmIssues.seed
    {:ok, bucket}
  end

  @doc"""
    Drop all entries in the Repo
  """
  def drop! do
    GenServer.cast(__MODULE__, :drop) 
  end

  @doc"""
    insert a new `ApmIssues.Issue` as `uuid, data, parent_id, children`
  """
  def insert(uuid,data,parent_id,children) do
    GenServer.cast(__MODULE__,{:insert, uuid, data, parent_id, children})
  end

  @doc"""
    Get Issue by UUID.

    If the given UUID doesn't exist, the function returns `:not_found`.
    Otherwise it returns a tuple of

    `{ %ApmIssues.Issue{}, parent_id, children[] }`

  """
  def get(uuid) do
    case GenServer.call(__MODULE__,{:get, uuid}) do
      nil -> :not_found
      found -> found
    end
  end
  
  @doc"""
    Return a list of all entries
  """
  def all() do
    GenServer.call(__MODULE__, :all )
  end

  @doc"""
    Return the count of all issues stored
  """
  def count() do
    GenServer.call(__MODULE__, :count )
  end

  @doc"""
    Return only entries with no parent
  """
  def root_issues() do
    GenServer.call(__MODULE__, :root_issues )
  end

  @doc"""
    Return a list of all entries with the given subject
  """
  def find_by_subject(subject) do
    GenServer.call(__MODULE__, {:find_by_subject, subject})
  end

  @doc"""
    Delete the entry with the given _uuid_ and all its children.
    If _uuid_ is a child, remove it from the parent.
  """
  def delete(uuid) do
    {_entity,parent_id,children} = ApmIssues.Repo.get(uuid)
    if parent_id, do: ApmIssues.Repo.remove_child(parent_id,uuid)
    drop_with_children(uuid,children)
  end

  @doc"""
    Add a `child_uuid` to the list of children of `parent_uuid`
  """
  def add_child(parent_uuid,child_uuid) do
    GenServer.cast(__MODULE__,{:add_child, parent_uuid, child_uuid})
  end

  @doc"""
    Remove the given `child_id` from `parent_id`
  """
  def remove_child(parent_id,child_id) do
    GenServer.cast(__MODULE__, {:remove_child, parent_id, child_id})
  end

  @doc"""
    Update the issue with the given _uuid_

    FIXME: This is still the old list of params. 
    FIXME: It should be `update(uuid, changeset)`
  """
  def update(uuid, subject, options) do
    changeset = %{subject: subject} |> Map.merge(options)
    GenServer.cast(__MODULE__, {:update, uuid, changeset})
  end


  defp drop_with_children(uuid,[]) do
    GenServer.cast(__MODULE__, {:remove, uuid})
  end

  defp drop_with_children(uuid,children) do
    Enum.each(children, fn(child_id) ->
      {_entity, _parent_id, sub_children} = get(child_id)
      drop_with_children(child_id, sub_children)
    end)
    drop_with_children(uuid,[])
  end

  #
  #  GenServer Callbacks
  #

  def handle_call(:all, _form, bucket) do
    {:reply, ApmRepository.Bucket.all(bucket), bucket}
  end

  def handle_call(:count, _form, bucket) do
    {:reply, ApmRepository.Bucket.count(bucket), bucket}
  end

  def handle_call(:root_issues, _form, bucket) do
    roots = ApmRepository.Bucket.select(bucket, fn({_uuid,{_entity,parent,_children}}) -> 
      parent == nil 
    end)
    {:reply, roots, bucket}
  end

  def handle_call({:find_by_subject, subject}, _form, bucket) do
    found = ApmRepository.Bucket.select(bucket, fn({_uuid,{entity,_parent,_children}}) -> 
      entity.subject == subject 
    end)
    {:reply, found, bucket}
  end

  def handle_call({:get, uuid}, _from, bucket) do
    item = ApmRepository.Bucket.get(bucket, uuid)
    {:reply, item, bucket}
  end

  def handle_cast({:insert, uuid, data, parent_id, children}, bucket) do
    ApmRepository.Bucket.add( bucket, uuid, data, parent_id, children)
    {:noreply, bucket}
  end

  def handle_cast({:remove, uuid}, bucket) do
    ApmRepository.Bucket.drop( bucket, [uuid])
    {:noreply, bucket}
  end

  def handle_cast({:remove_child, parent_id, child_id}, bucket) do
    ApmRepository.Bucket.remove_child(bucket, parent_id, child_id)
    {:noreply, bucket}
  end

  def handle_cast({:add_child, parent_uuid, child_uuid}, bucket) do
    ApmRepository.Bucket.add_child(bucket, parent_uuid, child_uuid)
    {:noreply, bucket}
  end

  def handle_cast({:update, uuid, changeset}, bucket) do
    ApmRepository.Bucket.update(bucket, uuid, changeset)
    {:noreply, bucket}
  end

  def handle_cast(:drop, bucket) do
    ApmRepository.Bucket.drop!(bucket)
    {:noreply, bucket}
  end
end
