defmodule Tree.Node.Supervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(Tree.Node.Supervisor, args)
  end

  def init(%{id: id, data: _data} = args) do
    children = [
      worker( Tree.Node, [args], restart: :temporary, id: id ) 
    ]
    supervise( children, strategy: :one_for_one )
  end

  def stop_children(pid) do
    Supervisor.which_children(pid) 
    |> Enum.reverse
    |> tl
    |> Enum.each( fn({id,_child_pid,_,_}) ->
      Supervisor.terminate_child(pid, id)
    end)
  end

  def data(pid) do
    [{_id,agent,_,_}|_] = Supervisor.which_children(pid) |> Enum.reverse
    Tree.Node.data(agent)
  end

  def children_ids(pid) do
    [_node|children] = Supervisor.which_children(pid) |> Enum.reverse
    children
    |> Enum.map( fn({id,_pid,_type,_args}) -> id end)
  end

  def parent(pid) do
    [{id,agent,_,_}|_] = Supervisor.which_children(pid) |> Enum.reverse
    IO.inspect ["XXXX",__MODULE__, "parent(pid)", pid, "Agent:", agent, id]
    Tree.Node.parent(agent)
  end


end
