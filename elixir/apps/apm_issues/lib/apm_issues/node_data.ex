defmodule ApmIssues.Node.Data do
  @moduledoc"""
  An `Agent` holding the state of an `ApmIssues.Issue` structure.
  """

  use Agent

  @doc"""
  Start the Agent with a node definition.
  See: `ApmIssues.Node`.
  """
  def start_link(%ApmIssues.Node{id: id, attributes: attributes}) do 
    Agent.start_link( fn() ->
      %ApmIssues.Issue{id: id, attributes: attributes}
    end)
  end

  @doc"""
  Stop the current Agent. Called from `ApmIssues.Node.Supervisor` when
  child gets terminated.
  """
  def stop(pid) do
    Agent.stop(pid)
  end
end

