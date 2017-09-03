defmodule ApmIssues.Node.Supervisor do
  require Logger

  use Supervisor

  def start_link(node) do
    Supervisor.start_link(ApmIssues.Node.Supervisor, [node])
  end

  def init([args]) do
    node = args |> Map.merge( %{ supervisor: self() } )

    children = [
      worker(ApmIssues.Node.Data, [node], restart: :temporary, id: node)
    ]
    supervise(children, strategy: :one_for_one)
  end

  def stop(server) do
    stop_children(server)
    Supervisor.stop(server)
  end

  def stop_children(server) do
    Supervisor.which_children(server)
    |> Enum.reverse
    |> Enum.each( fn({node,data,_,_}) ->
         Supervisor.terminate_child(server, data)
    end)
  end


end
