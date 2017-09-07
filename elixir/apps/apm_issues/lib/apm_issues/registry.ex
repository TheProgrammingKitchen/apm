defmodule ApmIssues.Registry do
  require Logger

  alias ApmIssues.{Node}

  @moduledoc"""
  Holds a `Map` of all registered nodes. The structure of this Map is:
      id => {id, pid_of_nodes_supervisor, pid_of_nodes_data_agent}

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

  ## Examples:
      iex> ApmIssues.Registry.state()
      %{}

      iex> ApmIssues.register_node( %ApmIssues.Node{id: 1, attributes: %{foo: :bar}})
      iex> %{ 1 => {1, supervisor, data}} = ApmIssues.Registry.state()
      iex> [1, is_pid(supervisor), is_pid(data)]
      [1,true,true]
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
  Register a new child `ApmIssues.Node`. The function is called by
  `ApmIssues.register(node,parent)`, so don't call it directly.
  """
  def register_child(server \\ @registry, node, parent) do
    GenServer.cast(server, {:register_child, node, parent})
  end

  @doc"""
  Lookup a previous registered `ApmIssue.Node` by id.
  The function is called by `ApmIssues.lookup(node)`, 
  so there is no need to call it directly.
  Lookup returns a tuple of `{ID, SUPERVISOR-PID, DATA-AGENT-PID}`
  """
  def lookup(server \\ @registry, id) do
    GenServer.call(server, {:lookup, id})
  end

  @doc"""
  Find by attribute. Searches inside `data.attributes` for the
  given search-term.

  Returns the node tuple if search for the given attribute was
  successful, :not_found if nothing was found, and :no_argument
  if no node has a definition of `attribute` in `attributes`.
  """
  def find_by(server \\ @registry, attribute, search_term) do
    GenServer.call(server, {:find_by, attribute, search_term})
  end

  @doc"""
  Stop the node with `id`.
  """
  def stop_node(server \\ @registry, id) do
    {^id, supervisor, _data} = lookup(server,id)
    GenServer.cast(server, {:stop_node, supervisor})
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

  def handle_call({:find_by, attribute, search_term}, _from, state) do
    return = 
      case find_by_attribute(state, attribute, search_term) do
        nil -> :not_found
        {_id,found} -> found
      end
    {:reply, return, state}
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

  def handle_cast({:register_child, child, parent }, state) do
    {_id, parent_supervisor, _parent_data} = parent
    {:ok, {_id,child_s,child_d}} = Node.Supervisor.register_child(parent_supervisor, child)
    Process.monitor(child_s)
    Process.monitor(child_d)
    {:noreply, state |> Map.put(child.id, {child.id, child_s, child_d})}
  end

  def handle_cast({:stop_node, supervisor}, state) do
    Supervisor.stop( supervisor )
    {:noreply, state }
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    case Map.values(state) 
           |> Enum.find( fn({_id,sup,_dat}) -> sup == pid end)
    do
      nil -> 
        {:noreply, state}
      {id,_sup,_dat} ->
        {:noreply, Map.delete(state,id)}
    end
  end

  defp stop_nodes(state) do
    state
    |> Map.to_list
    |> Enum.each( fn({_id, {_iid, supervisor, _data}}) ->
      if Process.alive?(supervisor), do: Node.Supervisor.stop(supervisor)
    end)
  end

  defp find_by_attribute(state, attribute, search_term) do
    state
      |> Map.to_list
      |> Enum.find( fn( {_key, {_id, _sup, data}} ) ->
        attr = ApmIssues.Node.Data.attributes(data)
        case attr[attribute] do
          nil -> false
          a -> a == search_term
        end
      end)
  end
end
