defmodule ApmIssues do
  require Logger

  @moduledoc"""
  `ApmIssues` is the main API of the OTP-Application.

  `ApmIssues.Application` starts the `ApmIssues.Registry` as
  a supervised worker.
  
  You usually call function of this public API only but do 
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
  Lookup a `ApmIssues.Node` by `id`

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
  Drops the element with the given `id`. Returns `:ok` or `:not_found`
  """
  def drop!(id) do
    case Registry.lookup(id) do
      nil -> 
        :not_found
      {_id,sup,_dat} ->
        Node.Supervisor.stop(sup)
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
