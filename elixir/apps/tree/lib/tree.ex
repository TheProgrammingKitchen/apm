defmodule Tree do

  alias Tree.{Registry, Node}

  def register_node( parent, id, data ) do
    %Node{ id: id, data: data }
    |> Registry.register(parent)
  end

  def lookup(func) when is_function(func), do: Registry.lookup(func)
  def lookup(id), do: lookup( fn({i,_p}) -> i == id end)

  def data({_id,pid}), do: data(pid)
  def data(pid) when is_pid(pid), do: Node.Supervisor.data(pid)
  def data(id), do: lookup(id) |> Tree.data()

  def id({id,_pid}), do: id
  def id(id), do: id

  def delete_all, do: Registry.delete_all
end
