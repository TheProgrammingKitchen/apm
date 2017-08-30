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

  test "read data from nodes in the tree" do
    root_node_pid = Tree.register_node( Tree.Supervisor, "Root Node", %{ something: "different"} )
    Tree.register_node( root_node_pid, "R1", %{ something: "1st"} )
    Tree.register_node( root_node_pid, "R2", %{ something: "2nd"} )
      |> Tree.register_node( "R2.1", %{ something: "2nd - 1"} )
    Tree.register_node( root_node_pid, "R3", %{ something: "3rd"} )

    assert %{something: "1st"} == Tree.data("R1")
    assert %{something: "2nd"} == Tree.data("R2")
    assert %{something: "2nd - 1"} == Tree.data("R2.1")
    assert %{something: "3rd"} == Tree.data("R3")
  end
end
