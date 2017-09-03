defmodule ApmIssues do
  require Logger
  alias ApmIssues.{Node, Registry}

  @doc"""
  Start supervisor and data agent for `ApmIssues.Node`
  """
  def register_node(node) do
    {:ok, supervisor} = start_node_supervisor(node) 
    {:ok, data_agent} = data_agent_pid(supervisor)
    entry =  {node.id, supervisor, data_agent}
    ApmIssues.Registry.register(entry)
    {:ok, entry}
  end

  def lookup(id) do
    case Registry.lookup(id) do
      nil -> :not_found
      entry -> entry
    end
  end

  def drop!(id) do
    case Registry.lookup(id) do
      nil -> 
        :not_found
      {id,sup,dat} ->
        ApmIssues.Node.Supervisor.stop(sup)
        :ok
    end
  end

  defp start_node_supervisor(node) do
    import Supervisor.Spec
    spec = supervisor(
             ApmIssues.Node.Supervisor, 
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
