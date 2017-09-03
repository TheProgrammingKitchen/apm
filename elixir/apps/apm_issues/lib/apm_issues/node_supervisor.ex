defmodule ApmIssues.Node.Supervisor do
  @moduledoc"""
  An `ApmIssues.Node.Supervisor` supervises a data-agent
  (`ApmIssues.Node.Data`) which get's started in `init`.
  The supervisor also supervises all children of this node,
  which are started dynamically.
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
  This callback is called during `ApmIssues.Node.Supervisor.start_link/1`.
  Don't call this function directly.
  """
  def init([args]) do
    node = args |> Map.merge( %{ supervisor: self() } )

    children = [
      worker(@data_node, [node], restart: :temporary, id: node)
    ]
    supervise(children, strategy: :one_for_one)
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
    stop_children(server)
    Supervisor.stop(server)
  end

  #
  # Private helpers
  #
  defp stop_children(server) do
    Supervisor.which_children(server)
    |> Enum.reverse
    |> Enum.each( fn({_node,data,_,_}) ->
         Supervisor.terminate_child(server, data)
    end)
  end

end
