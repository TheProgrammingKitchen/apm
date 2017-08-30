defmodule Tree do

  alias Tree.{Registry, Node}

  def register_node( parent, id, data ) do
    %Tree.Node{ id: id, data: data }
    |> Tree.Registry.register(parent)
  end

  def lookup(what) do
    Tree.Registry.lookup(what)
  end

  def delete_all do
    Tree.Registry.delete_all
  end
end
