defmodule ApmIssues.Node.Data do
  require Logger
  use Agent

  def start_link(%ApmIssues.Node{id: id, attributes: attributes}) do 
    {:ok, agent} = Agent.start_link( fn() ->
      %ApmIssues.Issue{id: id, attributes: attributes}
    end)
    {:ok, agent}
  end

  def stop(pid) do
    Logger.debug("STOP AGENT " <> inspect(pid))
    Agent.stop(pid)
  end
end

