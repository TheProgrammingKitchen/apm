defmodule Tree.Node.Supervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(Tree.Node.Supervisor, args)
  end

  def init(args) do
    %Tree.Node{data: _data, id: id} = args 
    children = [
      worker( Tree.Node, [args], restart: :temporary, id: id ) 
    ]
    supervise( children, strategy: :one_for_one )
  end
end
