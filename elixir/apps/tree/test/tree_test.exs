defmodule TreeTest do
  use ExUnit.Case
  doctest Tree

  setup do
    Tree.delete_all
    :ok
  end

  test "starting Registry with the Application" do
    assert Tree.Registry.nodes() == []
  end

  test "registering a new node and lookup for it" do
    Tree.register_node( Tree.Supervisor, "Root Node", %{ something: "different"} )
    {found,root_node_pid} = Tree.lookup( fn({id,_pid}) -> 
      id == "Root Node"
    end)
    assert is_pid(root_node_pid)
    assert found == "Root Node"
  end
end
