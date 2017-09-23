defmodule ApmIssues.Node.Supervisor do
  @moduledoc"""
  An `ApmIssues.Node.Supervisor` supervises a data-agent
  (`ApmIssues.Node.Data`) which get's started in `init`.
  The supervisor also supervises all children of this node,
  which are started dynamically by `ApmIssues.register_node/2`
  """

  use Supervisor

  @supervisor ApmIssues.Node.Supervisor
  @data_node  ApmIssues.Node.Data

  @doc"""
  Start a new Node's Supervisor for a `ApmIssues.Node`

  ## Example:
        iex> node = %ApmIssues.Node{attributes: %{foo: "bar"}, id: "ID1"} 
        iex> {:ok, pid} = ApmIssues.Node.Supervisor.start_link(node)
        iex> is_pid(pid)
        true
  """
  def start_link(node) do
    Supervisor.start_link(@supervisor, [node])
  end

  @doc"""
  Initialize the Supervisor.
  Start a Data Agent `ApmIssues.Node.Data` as a supervisor child.
  This callback gets called during `ApmIssues.Node.Supervisor.start_link/1`.
  Don't call this function directly. It also injects the pid of this
  supervisor to the state of the node.
  """
  def init([args]) do
    node = args |> Map.merge( %{ supervisor: self() } )

    children = [
      worker(@data_node, [node], restart: :temporary, id: node)
    ]
    supervise(children, strategy: :one_for_one)
  end

  @doc"""
  The data-agent is the last child in the list of `which_children`
  of the superviser (because it gets started first and children are
  added to the top of the list.
  """
  def data_pid(pid) do
    {_data,pid,_,_} = Supervisor.which_children(pid)
                        |> Enum.reverse
                        |> hd
    pid
  end

  @doc"""
  Return a list of ids of all children. The first child (after reverse)
  is the data-agent of the node and will not be returned in the list.
  """
  def children_ids(pid) do
    Supervisor.which_children(pid)
      |> Enum.reverse
      |> tl
      |> Enum.map( fn { id, _pid, _, _ } -> id end)
  end


  @doc"""
  Register a child. It starts a new node-supervisor as a child of this node's
  supervisor tree.
  """
  def register_child(parent_supervisor, child) do
    spec = supervisor(ApmIssues.Node.Supervisor, [child], id: child.id, restart: :temporary)
    {:ok, pid} = Supervisor.start_child(parent_supervisor, spec)
    {:ok, {child.id,pid,ApmIssues.data_pid(pid)}}
  end

  @doc"""
  Stop the node. The function stops all children of this node and
  finally stops the supervisor itself.

  ## Example:
        iex> node = %ApmIssues.Node{attributes: %{foo: "bar"}, id: "ID1"} 
        iex> {:ok, pid} = ApmIssues.Node.Supervisor.start_link(node)
        iex> Supervisor.which_children(pid) |> Enum.count
        1
        iex> ApmIssues.Node.Supervisor.stop(pid)
        iex> Process.alive?(pid)
        false
  """
  def stop(server) do
    stop_children_incl_data_agent(server)
    Supervisor.stop(server)
  end

  #
  # Private helpers
  #
  defp stop_children_incl_data_agent(server) do
    Supervisor.which_children(server)
    |> Enum.each( fn({_node,data,_,_}) ->
         Supervisor.terminate_child(server, data)
    end)
  end

end
