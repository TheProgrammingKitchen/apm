defmodule Dictionary.BucketList do
  @moduledoc"""
  Bucketlist can start and monitor Buckets.
  """
  use GenServer

  def start_link([]) do
    GenServer.start_link( __MODULE__, [], name: __MODULE__)
  end

  def start_bucket(name) do
    bucket = register_bucket(name)
    GenServer.cast(__MODULE__, {:start, name, bucket})
    {:ok, bucket}
  end

  def lookup(name) do
    GenServer.call(__MODULE__, {:lookup, name})
  end

  #
  # GenServer callbacks
  #

  def handle_call({:lookup, name_to_find}, _from, state) do
    found = 
      Enum.find(state, :not_found, fn({name, _bucket}) -> name == name_to_find end)
    {:reply, found, state}
  end

  def handle_cast({:start, name, bucket}, state) do
    Process.monitor(bucket)
    {:noreply, [{name,bucket} | state]}
  end

  def handle_info({:DOWN,_ref,:process,pid,_reason},state) do
    {:noreply, Enum.reject(state, fn({_name,p}) -> p == pid end) }
  end

  defp register_bucket(name) do
    import Supervisor.Spec
    spec = supervisor( Dictionary.Bucket,[], id: name, restart: :temporary)
    case Supervisor.start_child(Dictionary.Supervisor, spec) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end


end
