defmodule TreeTest do
  use ExUnit.Case
  doctest Tree

  setup do
    Tree.delete_all
    :ok
  end

  test "starting empty Registry with the Application." do
    assert Tree.Registry.nodes() == []
  end

  test "read data from nested nodes in the tree" do

    # Given:
    #
    # + R1
    # + R2
    # +-- R2.1
    # +-+ R2.2
    # | +-- R2.2.1
    # + R3

    # Root Node + R1
    root_node = Tree.register_node( Tree.Supervisor, "Root Node", %{ something: "different"} )
    root_node |> Tree.register_node("R1", %{ something: "1st"} )
    # R2, R2.1, R2.2, and R2.2.1
    sub_node = Tree.register_node( root_node, "R2", %{ something: "2nd"} )
    sub_node |> Tree.register_node( "R2.1", %{ something: "2nd - 1"} )
    sub_sub_node = sub_node |> Tree.register_node( "R2.2", %{ something: "2nd - 2"} )
    sub_sub_node |> Tree.register_node( "R2.2.1", %{ something: "2nd - 2.1"} )
    # R3
    root_node |> Tree.register_node("R3", %{ something: "3rd"} )

    assert_node("Root Node", %{something: "different"})
    assert_node("R1", %{something: "1st"})
    assert_node("R2", %{something: "2nd"})
    assert_node("R3", %{something: "3rd"})
    assert_node("R2.1", %{something: "2nd - 1"})
    assert_node("R2.2", %{something: "2nd - 2"})
    assert_node("R2.2.1", %{something: "2nd - 2.1"})
  end

  defp assert_node(id, data) do
    assert id == Tree.id(id)
    assert data == Tree.data(id)
  end
end
