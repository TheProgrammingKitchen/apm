defmodule ApmIssues do
  require Logger

  @moduledoc"""
  `ApmIssues` is the main API of the OTP-Application.

  `ApmIssues.Application` starts the `ApmIssues.Registry` as
  a supervised worker.
  
  You usually call functions of this public API only but do 
  not use `ApmIssues.Registry` directly.
  """

  alias ApmIssues.{Node,Registry}

  @doc"""
  Register a new `ApmIssues.Node`.
  Returns a tuple of `{:ok, {id, supervisor_pid, data_agent_pid}`

  ## Example:
      iex> {:ok, {id,supervisor,data}} = ApmIssues.register_node( %ApmIssues.Node{id: 1} )
      iex> [id,true,true] = [id, is_pid(supervisor), is_pid(data)]
      iex> id
      1
  """
  def register_node(node) do
    {_id, _supervisor, _data_agent} = entry = start_node(node)
    Registry.register(entry)
    {:ok, entry}
  end

  @doc"""
  Register `node` as a child of node whith `parent_id`.
  """
  def register_node(node, parent_id) do
    parent = ApmIssues.lookup(parent_id) 
    node
    |> Map.merge( %{parent: parent} )
    |> Registry.register_child(parent)
  end

  @doc"""
  Get the data-agent pid of the given `node`.
  """
  def data_pid(node) do
    Node.Supervisor.data_pid(node)
  end

  @doc"""
  Lookup a `ApmIssues.Node` by `id` and returns a tuple of
  `{ found_id, supervisor_pid, data_agent_pid }`.

  ## Examples:
      iex> ApmIssues.register_node( %ApmIssues.Node{id: 1} )
      iex> {id,_sup,_dat} = ApmIssues.lookup(1)
      iex> id
      1
      iex> ApmIssues.lookup(:somethig_not_there)
      :not_found
  """
  def lookup(id) do
    case Registry.lookup(id) do
      nil -> :not_found
      entry -> entry
    end
  end

  @doc"""
  Get the parent-id of a node or :no_parent
  """
  def parent_id(node_id) do
    case lookup(node_id) do
      :not_found -> :not_found
      {_child_id, _supervisor, data} -> ApmIssues.Node.Data.parent_id(data)
    end
  end

  @doc"""
  Get list of ids of all children of the parent `node`
  """
  def children_ids(node) do
    {_node_id,node_supervisor,_data} = lookup(node)
    ApmIssues.Node.Supervisor.children_ids(node_supervisor)
  end

  @doc"""
  Drops the element with the given `id` and all it's children.
  Returns `:ok` or `:not_found`
  """
  def drop!(id) do
    case Registry.lookup(id) do
      nil -> 
        :not_found
      {id_found,sup,_dat} ->
        ApmIssues.children_ids(id_found)
          |> Enum.each( &ApmIssues.drop!(&1) ) 
        Process.exit(sup,:kill)
        :ok
    end
  end

  @doc"""
  Not implemented yet. Will be needed by the Phoenix implementation.
  """
  def seed() do
    Logger.debug inspect(__MODULE__) <> ".seed() is not implemented."
  end

  #
  # Private Helpers
  #

  defp start_node(node) do
    {:ok, supervisor} = start_node_supervisor(node) 
    {:ok, data_agent} = data_agent_pid(supervisor)
    {node.id, supervisor, data_agent}
  end
  
  defp start_node_supervisor(node) do
    import Supervisor.Spec
    spec = supervisor(
             Node.Supervisor, 
             [node], 
             id: node.id,  
             restart: :temporary,
          )

    Supervisor.start_child(ApmIssues.Supervisor, spec)
  end

  defp data_agent_pid(supervisor) do
    {_node,data_child,_,_} = Supervisor.which_children(supervisor)
                   |> Enum.reverse
                   |> hd
    {:ok, data_child}
  end

end
