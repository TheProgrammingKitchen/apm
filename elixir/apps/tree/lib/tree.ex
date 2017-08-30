defmodule Tree do

  alias Tree.{Registry, Node}

  def register_node( parent, id, data ) do
    %Tree.Node{ id: id, data: data }
    |> Tree.Registry.register(parent)
  end

  def lookup(what) do
    Tree.Registry.lookup(what)
  end

  def data({_id,pid}), do: data(pid)
  def data(pid) when is_pid(pid) do
    Tree.Node.Supervisor.data(pid)
  end

  def data(search_id) do
    lookup( fn({id,_pid}) -> id == search_id end)
    |> Tree.data()
  end

  def delete_all do
    Tree.Registry.delete_all
  end
end
