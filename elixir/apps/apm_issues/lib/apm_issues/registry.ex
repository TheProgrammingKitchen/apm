defmodule ApmIssues.Registry do
  require Logger
  use GenServer

  @registry __MODULE__

  def start_link(_) do
    GenServer.start_link(@registry, %{}, name: @registry)
  end

  def init(state) do
    {:ok, state}
  end

  def state(server \\ @registry) do
    GenServer.call(server, :state) 
  end

  def register(server \\ @registry, node) do
    GenServer.cast(server, {:register, node})
  end

  def lookup(server \\ @registry, id) do
    GenServer.call(server, {:lookup, id})
  end

  def drop!(server \\ @registry) do
    GenServer.call(server, :drop)
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

  def handle_cast({:register, {id,data,supervisor} = node}, state) do
    Process.monitor(supervisor)
    Process.monitor(data)
    {:noreply, Map.put(state, id, {id, data, supervisor})}
  end

  def handle_call(:drop, _from, state) do
    state
    |> Map.to_list
    |> Enum.each( fn({id, {id, supervisor, data}}) ->
      ApmIssues.Node.Supervisor.stop(supervisor)
    end)
    {:reply, :ok, %{}}
  end

  def handle_info({:DOWN, _ref, :process, pid, reason}, state) do
    Logger.debug( "REGISTRY HANDLE :DOWN OF PID " <> inspect(pid) <> " REASON: " <> inspect(reason) )
    case Map.values(state) 
           |> Enum.find( fn({id,sup,dat}) ->
                sup == pid
              end)
    do
      nil -> {:noreply, state}
      {id,_sup,_dat} -> {:noreply, Map.delete(state,id)}
    end
  end
end
