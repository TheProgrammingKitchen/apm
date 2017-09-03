defmodule ApmIssues.Registry do
  @moduledoc"""
  Holds a `Map` of all registered nodes. The structure of this Map is:
      {id, pid_of_nodes_supervisor, pid_of_nodes_data_agent}

  When new nodes are registered, their processes will be monitored
  and the node will be removed from the registry whenever a node
  terminates.
  """
  use GenServer
  @registry __MODULE__

  # GenServer behavior

  @doc false
  def start_link(_) do
    GenServer.start_link(@registry, %{}, name: @registry)
  end

  @doc false
  def init(state) do
    {:ok, state}
  end

  # Public API

  @doc"""
  Get the current state of the Registry

  ## Example:
      iex> ApmIssues.Registry.state()
      %{}
  """
  def state(server \\ @registry) do
    GenServer.call(server, :state) 
  end

  @doc"""
  Register a new `ApmIssues.Node`. The function is called by
  `ApmIssues.register(node)`, so don't call it directly.
  """
  def register(server \\ @registry, node) do
    GenServer.cast(server, {:register, node})
  end


  @doc"""
  Lookup a previous registered `ApmIssue.Node` by id.
  The function is called by `ApmIssues.register(node)`, 
  so don't call it directly.
  """
  def lookup(server \\ @registry, id) do
    GenServer.call(server, {:lookup, id})
  end

  @doc"""
  Drop/terminate all entries in Registry. 
  """
  def drop!(server \\ @registry) do
    case Mix.env do
      :test -> GenServer.call(server, :drop)
      _ -> GenServer.cast(server, :drop)
    end
  end

  #
  # GenServer Callbacks
  #
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:lookup, id}, _from, state) do
    {:reply, Map.get(state, id), state}
  end

  def handle_call(:drop, _from, state) do
    stop_nodes(state)
    {:reply, :ok,  %{}}
  end

  def handle_cast(:drop, state) do
    stop_nodes(state)
    {:noreply, %{}}
  end

  def handle_cast({:register, {id,data,supervisor} }, state) do
    Process.monitor(supervisor)
    Process.monitor(data)
    {:noreply, Map.put(state, id, {id, data, supervisor})}
  end


  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    case Map.values(state) 
           |> Enum.find( fn({_id,sup,_dat}) ->
                sup == pid
              end)
    do
      nil -> {:noreply, state}
      {id,_sup,_dat} -> {:noreply, Map.delete(state,id)}
    end
  end

  defp stop_nodes(state) do
    state
    |> Map.to_list
    |> Enum.each( fn({_id, {_iid, supervisor, _data}}) ->
      ApmIssues.Node.Supervisor.stop(supervisor)
    end)
  end
end
