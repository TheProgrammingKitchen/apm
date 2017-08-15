defmodule ApmIssues.Repo do

  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__,{}, name: __MODULE__)
  end


  def init(name) do
    {:ok, _t, bucket} = ApmRepository.new_bucket({name, ApmIssues.Issue})
    {:ok, bucket}
  end

  def insert(uuid,data,parent_id,children) do
    GenServer.cast(__MODULE__,{:insert, uuid, data, parent_id, children})
  end

  def get(uuid) do
    case GenServer.call(__MODULE__,{:get, uuid}) do
      nil -> :not_found
      found -> found
    end
  end
  
  def all() do
    GenServer.call(__MODULE__, :all )
  end

  def count() do
    GenServer.call(__MODULE__, :count )
  end

  def root_issues() do
    GenServer.call(__MODULE__, :root_issues )
  end

  def find_by_subject(subject) do
    GenServer.call(__MODULE__, {:find_by_subject, subject})
  end

  def drop_with_children(uuid,children) do
    Enum.each(children, fn(child_id) ->
      {_entity, parent_id, sub_children} = get(child_id)
      drop_with_children(child_id, sub_children)
    end)
    GenServer.cast(__MODULE__, {:remove, uuid})
  end

  def add_child(parent_uuid,child_uuid) do
    GenServer.cast(__MODULE__,{:add_child, parent_uuid, child_uuid})
  end

  def remove_child(parent_id,child_id) do
    {entity, parent_id, children} = ApmIssues.Repo.get(parent_id)
    GenServer.cast(__MODULE__, {:remove_child, parent_id, child_id})
  end

  def update(uuid, subject, options) do
    {entity, parent_id, children} = ApmIssues.Repo.get(uuid)
    changeset = %{subject: subject} |> Map.merge(options)
    GenServer.cast(__MODULE__, {:update, uuid, changeset})
  end

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
    ApmRepository.Bucket.add( bucket,
      uuid, data, parent_id, children)
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
end
