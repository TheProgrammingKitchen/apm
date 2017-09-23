defmodule ApmIssues.Node.Data do
  require Logger
  @moduledoc"""
  An `Agent` holding the state of an `ApmIssues.Issue` structure.
  """

  use Agent

  @doc"""
  Start the Agent with a node definition.
  See: `ApmIssues.Node`.
  """
  def start_link(%ApmIssues.Node{id: id, attributes: attributes, parent: parent}) do 
    Agent.start_link( fn() ->
      { %ApmIssues.Issue{id: id, attributes: attributes}, parent: parent}
    end)
  end

  @doc"""
  Stop the current Agent. Called from `ApmIssues.Node.Supervisor` when
  child gets terminated.
  """
  def stop(pid) do
    Agent.stop(pid)
  end

  @doc"""
  Get data from the data agent of pid
  """
  def data(pid) do
    Agent.get(pid, fn(data) -> data end)
  end

  @doc"""
  Get attributes from the data agent of pid
  """
  def attributes(pid) do
    {node, _parent} = data(pid)
    node.attributes
  end

  @doc"""
  Update attributes
  """
  def update(pid, changeset) do
    Agent.update(pid, fn({data, parent}) ->
      {update_node(data,changeset), parent}
    end)
  end

  @doc"""
  Get the parent id of a given data-agent or :no_parent.
  """
  def parent_id(pid) do
    case parent_spec(pid) do
      nil -> :no_parent
      {id,_sup,_data} -> id
    end
  end

  defp parent_spec(pid) do
    Agent.get(pid, fn({_data,parent_spec}) -> 
      parent_spec[:parent] 
    end)
  end

  defp update_node(data,changeset) do
    Map.merge(data.attributes, changeset)
    |> update_attributes(data)
  end

  defp update_attributes(new_attributes, data) do
    Map.merge(data, %{attributes: new_attributes})
  end
end

