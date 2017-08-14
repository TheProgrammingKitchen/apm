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
    GenServer.call(__MODULE__,{:get, uuid})
  end
  
  def all() do
    GenServer.call(__MODULE__, :all )
  end

  def root_issues() do
    GenServer.call(__MODULE__, :root_issues )
  end

  def handle_call(:all, _form, bucket) do
    IO.inspect "HANDLE ALL ISSUES"
    {:reply, ApmRepository.Bucket.all(bucket), bucket}
  end

  def handle_call(:root_issues, _form, bucket) do
    roots = ApmRepository.Bucket.select(bucket, fn({_uuid,{_entity,parent,_children}}) -> 
      parent == nil 
    end)
    {:reply, roots, bucket}
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

end
