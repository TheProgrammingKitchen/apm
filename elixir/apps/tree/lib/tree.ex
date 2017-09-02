defmodule Tree do

  alias Tree.{Registry, Node}

  def register_node( parent, id, data ) when is_pid(parent) do
    %Node{ id: id, data: data, parent_pid: parent }
    |> Registry.register(parent)
  end
  def register_node( parent, id, data ) do
    Process.whereis(parent)
    |> register_node(id, data)
  end

  def lookup(func) when is_function(func), do: Registry.lookup(func)
  def lookup(id), do: lookup( fn({i,_p}) -> i == id end)

  def data({_id,pid}), do: data(pid)
  def data(pid) when is_pid(pid), do: Node.Supervisor.data(pid)
  def data(id), do: lookup(id) |> Tree.data()

  def id({id,_pid}), do: id
  def id(id), do: id

  def delete_all, do: Registry.delete_all

  def children_ids({_root_id,pid}), do: children_ids(pid)
  def children_ids(pid) when is_pid(pid), do: Node.Supervisor.children_ids(pid)
  def children_ids(root_id) do 
    lookup(root_id) |> Tree.children_ids()
  end

  def parent({_root_id,pid}), do: parent(pid)
  def parent(pid) when is_pid(pid), do: Node.Supervisor.parent(pid)
  def parent(child) do 
    lookup(child) |> Tree.parent()
  end

end
