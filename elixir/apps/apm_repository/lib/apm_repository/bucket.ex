defmodule ApmRepository.Bucket do
  @moduledoc"""
    `ApmRepository.Bucket` is a `GenServer` holding a map of

        `"uuid" => { %entity, parent_id, children[]}`

    where _children_ is a list of `[uuid1, uuid2, ...]`


        %{
           "uuid-1" => {
                         %{ some: "Value", is: 46 },
                         nil, # no parent
                         ["uuid-2", "uuid-3", ...]
                       },
           "uuid-2" => { %{ some: "other", is: 42 }, "uuid-1", [] }
           "uuid-3" => { %{ some: "thing", is: 99 }, "uuid-1", [] }
         }

    **do not use 'Atoms' as keys!**
  """

  use GenServer

  @doc"Called from `ApmRepository.Dictionary` on `new_bucket`"
  def start_link(_entries) do
    GenServer.start_link(__MODULE__, %{})
  end


  @doc"""
    Add an `entry` to the `bucket` using `uuid` as a key.

    ### Example

      iex> {:ok, _type, bucket} = ApmRepository.Dictionary.new_bucket({"people", %{}})
      iex> ApmRepository.Bucket.add bucket, "ID1", %{name: "Frank"}
      iex> ApmRepository.Bucket.get bucket, "ID1"
      {%{name: "Frank"}, nil, []}
  """
  def add bucket, uuid, entry, parent_id \\ nil, children \\ [] do
    GenServer.cast(bucket, {:add, uuid, {entry, parent_id, children}})
  end

  @doc"""
  Remove an `entry` to the `bucket` using `uuid` as a key.

  ### Example

        iex> {:ok,_type,pid} = ApmRepository.new_bucket({"people", %{}})
        iex> ApmRepository.Bucket.add(pid, "ID1", %{name: "Frank"})
        iex> ApmRepository.Bucket.get(pid, "ID1")
        {%{name: "Frank"}, nil, []}
        iex> ApmRepository.Bucket.remove(pid, "ID1")
        iex> ApmRepository.Bucket.get(pid, "ID1")
        nil
        
  """
  def remove bucket, uuid do
    GenServer.cast(bucket, {:remove, uuid})
  end

  @doc"Return all entries in the bucket"
  def all bucket do
    GenServer.call(bucket, :all)
  end

  @doc"""
  Get an `entry` out of the `bucket` using `uuid` as a key.

  ### Example

        iex> {:ok,_type,pid} = ApmRepository.new_bucket({"people", %{}})
        iex> ApmRepository.Bucket.add(pid, "ID1", %{name: "Frank"})
        iex> ApmRepository.Bucket.get(pid, "ID1")
        {%{name: "Frank"},nil,[]}
        iex> ApmRepository.Bucket.get(pid, "UNKNOWN ID")
        nil
        
  """
  def get bucket, uuid do
    GenServer.call(bucket, {:get, uuid})
  end

  @doc"""
    select (map) all entries for which the given
    function retrurns a truthy value
  """
  def select(bucket, fun ) do
    ApmRepository.Bucket.all(bucket)
    |> Enum.filter( fn(e) -> fun.(e) end )
  end

  @doc"""
    Return a list of UUIDs
  """
  def children bucket, parent_id do
    GenServer.call(bucket, {:children, parent_id})
  end

  @doc"""
    Return the parent id of an entry
  """
  def parent bucket, child_id do
    GenServer.call(bucket, {:parent, child_id})
  end


  @doc"""
  Update an `entry` in the `bucket` using `uuid` as a key and 
  `changeset`.

  ### Example

        iex> # Add entry
        iex> {:ok,_type,pid} = ApmRepository.new_bucket({"people", %{}})
        iex> ApmRepository.Bucket.add(pid, "ID1", %{name: "Frank"})
        iex> #
        iex> # Modify entry
        iex> :ok = ApmRepository.Bucket.update(pid, "ID1", %{prof: "Music"})
        iex> ApmRepository.Bucket.get(pid, "ID1")
        {%{name: "Frank", prof: "Music"}, nil, []}
        
  """
  def update bucket, uuid, changeset do
    GenServer.cast(bucket, {:update, uuid, changeset})
  end


  @doc"""
  Count the number of entries in bucket
  """
  def count bucket do
    GenServer.call(bucket, :count)
  end


  @doc"""
  Empty the bucket.
  """
  def drop! bucket do
    GenServer.cast(bucket,:clear)
  end

  @doc"""
  Drop entries from bucket
  """
  def drop(bucket, uuids) do
    GenServer.cast(bucket, {:drop, uuids})
  end


  @doc"""
  Add a child to an entry

  ### Example

      iex> {:ok,_type,bucket} = ApmRepository.new_bucket({"people", %{}})
      iex> ApmRepository.Bucket.add(bucket, "ID1", %{name: "Frank Zappa"})
      iex> ApmRepository.Bucket.add_child(bucket,"ID1", "ID1.1", %{name: "Moon Unit Zappa"})
      iex> ApmRepository.Bucket.add_child(bucket,"ID1", "ID1.2", %{name: "Dweezil Zappa"})
      iex> ApmRepository.Bucket.add_child(bucket,"ID1", "ID1.3", %{name: "Ahmet Zappa"})
      iex> {_frank, _parent_id, _children} = ApmRepository.Bucket.get(bucket, "ID1")
      {
        %{name: "Frank Zappa"},
        nil,
        ["ID1.3", "ID1.2", "ID1.1"]
      }

  """
  def add_child(bucket, parent_id, child_id, entity) do
    add(bucket,child_id, entity, parent_id, [] )
    GenServer.cast(bucket, {:add_child, parent_id, child_id})
    bucket
  end

  def add_child(bucket, parent_uuid, child_uuid) do
    GenServer.cast(bucket, {:add_child, parent_uuid, child_uuid})
    bucket
  end

  def remove_child(bucket, parent_id, child_id) do
    GenServer.cast(bucket, {:remove_child, parent_id, child_id})
  end
  #
  # Gen Server Callbacks
  #
  def handle_call({:get, uuid}, _from, bucket) do
    {:reply, Map.get(bucket, uuid), bucket}
  end

  def handle_call(:all, _from, bucket) do
    {:reply, bucket, bucket}
  end

  def handle_call(:count, _from, bucket) do
    cnt = Map.keys(bucket) |> Enum.count
    {:reply, cnt, bucket}
  end

  def handle_call({:children,uuid}, _from, bucket) do
    {_entry,_parent,children} = Map.get(bucket,uuid)
    {:reply, children, bucket}
  end

  def handle_call({:parent,uuid}, _from, bucket) do
    {_entry,parent_id,_children} = Map.get(bucket,uuid)
    {:reply, parent_id, bucket}
  end

  def handle_cast({:remove, uuid}, bucket) do
    {:noreply, Map.drop(bucket, [uuid])}
  end

  def handle_cast({:update, uuid, changeset}, bucket) do
    state = Map.update!( bucket, uuid, fn({e,parent_id,children}) -> {Map.merge(e,changeset),parent_id, children} end)
    {:noreply, state}
  end

  def handle_cast(:clear, _bucket) do
    {:noreply, %{}}
  end

  def handle_cast({:add, uuid, {entry, parent_id, children}}, bucket) do
    {:noreply, Map.put(bucket, uuid, {entry, parent_id, children})}
  end

  def handle_cast({:add_child, parent_id, child_id}, bucket) do
    state =  Map.update!( bucket, parent_id, fn({e,parent_id,children}) -> 
      {e, parent_id, [child_id|children]} 
    end)
    {:noreply, state}
  end

  def handle_cast({:remove_child, parent_id, child_id}, bucket) do
    state =  Map.update!( bucket, parent_id, fn({e,parent_id,children}) -> 
      {e, parent_id, Enum.drop(children, child_id)} 
    end)
    {:noreply, state}
  end

  def handle_cast({:drop, uuids}, bucket) do
    {:noreply, Map.drop(bucket, uuids)}
  end
end
