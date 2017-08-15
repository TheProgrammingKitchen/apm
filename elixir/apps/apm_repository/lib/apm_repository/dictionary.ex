defmodule ApmRepository.Dictionary do
 
  @moduledoc"""
    The `ApmRepository.Dictionary` is a `GenServer` and 
    manages the state of registered `ApmRepository.Bucket` processes
    in the form

        [{name, type, bucket},...]

    _Buckets_ are monitored and removed from the dictionary in case
    they terminate.

        name ....... Unique Bucket-name (anything works though, 
                     using UUID is highly recommended)
        type ....... A module/structure of any type, implementing 
                     the protocol, defined in `ApmRepository.Node`
        bucket ..... The `PID` of the monitored process
                    
  """

  use GenServer

  @doc"""
    Dictionary is started as a supervisor in application. 
    No need to call this function manually. Because `Dictionary`'s
    `GenServer` is named by `__MODULE__` it is not possible to
    start more than one `Dictionary` (with current architecture)
  """
  def start_link(init_state \\ []) do
    GenServer.start_link(__MODULE__, init_state, name: __MODULE__)
  end


  @doc"""
    Create and monitor a new bucket.
    A `ApmRepository.Bucket` handles a map of _nodes_ where 
    any entry is a tuple of `{uuid, pid_node, [{child_id,child_pid},{},...]}`

    ### Example

          iex> {:ok,type,pid} = ApmRepository.Dictionary.new_bucket({"People", %{}})
          iex> is_pid(pid)
          true
          iex> type
          %{}
  """
  def new_bucket( {name, type} ) do
    GenServer.call(__MODULE__, {:new_bucket, {name, type}})
  end

  @doc"Return the number of registered `ApmRepository.Bucket`s in _dictionary_"
  def count() do
    GenServer.call(__MODULE__, :count)
  end

  @doc"""
    Empty the dictionary.

    FIXME: Make sure all processes stopped and/or restarted 
  """
  def drop!() do
    GenServer.cast(__MODULE__, :drop)
  end

  @doc"""
    Push an item to a bucket
  """
  def push(item, bucket_name) do
    GenServer.cast(__MODULE__, {:push, item, bucket_name})
  end

  def handle_cast({:push, item, bucket_name}, dictionary) do
    {_name,_type,bucket} = Enum.find(dictionary, fn({name,_type,_pid})->
      name == bucket_name
    end)
    ApmRepository.Bucket.add(bucket, item.uuid, item)
    {:noreply, dictionary}
  end

  # GenServer Callbacks

  def init(_dictionary) do
    {:ok, %{}}
  end

  def handle_cast(:drop, dictionary) do
    dictionary
    |> Enum.each( fn({name,type,bucket}) ->
      IO.inspect ["CLEAR DICTIONARY", name, type, bucket]
      ApmRepository.Bucket.drop!(bucket)
    end)
    {:noreply, [] }
  end

  def handle_call(:count, _from, dictionary) do
    {:reply, Enum.count(dictionary), dictionary}
  end

  def handle_call({:new_bucket, {name, type}}, _from, dictionary) do
    {:ok, bucket} = ApmRepository.Bucket.start_link({name, type})
    Process.monitor(bucket)
    {:reply, {:ok, type, bucket}, [ {name, type, bucket} | dictionary ]  }
  end

  def handle_info( {:DOWN, _ref, :process, pid, _reason}, dictionary ) do
    {
      :noreply, 
      Enum.reject(dictionary, fn({_name,_type,ppid}) -> ppid == pid end) 
    }
  end

end
