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
  Find by :attribute

  ## Example:
      iex> ApmIssues.register_node( %ApmIssues.Node{id: 1, attributes: %{subject: "Subject one"}} )
      iex> ApmIssues.register_node( %ApmIssues.Node{id: 1.1, attributes: %{subject: "Subject one.one"}}, 1 )
      iex> ApmIssues.find_by(:subject, "Not there")
      :not_found
      iex> ApmIssues.find_by(:not_existing, "Attribute")
      :not_found
      iex> {node,_sup,_dat} = ApmIssues.find_by(:subject,"Subject one")
      iex> node
      1
      iex> {node,_sup,_dat} = ApmIssues.find_by(:subject,"Subject one.one")
      iex> node
      1.1
  """
  def find_by(attr_name, search) do
    Registry.find_by(attr_name, search)
  end

  @doc"""
  Get all root nodes

  ## Example:
      iex> ApmIssues.register_node( %ApmIssues.Node{ id: 1 } )
      iex> ApmIssues.register_node( %ApmIssues.Node{ id: 1.1 }, 1 )
      iex> ApmIssues.register_node( %ApmIssues.Node{ id: 2 } )
      iex> ApmIssues.register_node( %ApmIssues.Node{ id: 2.2 }, 2 )
      iex> ApmIssues.roots()
      [1,2]
  """
  def roots() do
    Registry.state
      |> Enum.filter( fn({id, _node}) ->
        ApmIssues.parent_id(id) == :no_parent
      end)
      |> Enum.map( fn({id, _node}) -> id end)
  end

  @doc"""
  Get data of a node as `%ApmIssues.Issue{}`

  ## Example:
      iex> ApmIssues.register_node( %ApmIssues.Node{ id: 1, attributes: %{foo: :bar} } )
      iex> ApmIssues.data(1)
      %ApmIssues.Issue{attributes: %{foo: :bar}, id: 1}
  """
  def data(id) do
    {node,_parent} = case lookup(id) do
      {_node, _sup, data} -> ApmIssues.Node.Data.data(data)
      error -> {:error, inspect(error)}
    end
    node
  end

  @doc"""
  Get attributes of a data nodes as `%{}`

  ## Example:
      iex> ApmIssues.register_node( %ApmIssues.Node{ id: 1, attributes: %{foo: :bar} } )
      iex> ApmIssues.attributes(1)
      %{foo: :bar}
  """
  def attributes(id) do
     case lookup(id) do
      :not_found -> :not_found
      {_node, _sup, data} -> 
        {node,_parent} = ApmIssues.Node.Data.data(data)
        node.attributes || %{}
    end
  end

  @doc"""
  Update attributes of the node with `id` by `Map.merge(attributes, changeset)`

  ## Example:
      iex> ApmIssues.register_node( %ApmIssues.Node{ id: 1, attributes: %{foo: :bar} } )
      iex> ApmIssues.update(1, %{foo: :updated_baz} )
      iex> ApmIssues.attributes(1)
      %{foo: :updated_baz}
  """
  def update(id, changeset) do
     case lookup(id) do
      :not_found -> :not_found
      {_node, _sup, data} -> ApmIssues.Node.Data.update(data, changeset)
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
  seeds some test data for ApmPx Phoenix application
  """
  def seed(issues) do
    Enum.each(issues, fn(issue) ->
      case issue do
        %ApmIssues.Node{ id: id, attributes: attributes} -> ApmIssues.register_node(issue)
        {node, parent} -> ApmIssues.register_node(node, parent)
        _ -> Logger.warn("UNKNOWN ISSUE IN SEED: " <> inspect(issue))
      end
    end)
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
    attr = Map.merge( %{id: UUID.uuid1()}, node )
    import Supervisor.Spec
    spec = supervisor(
             Node.Supervisor, 
             [attr], 
             id: attr.id, 
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
