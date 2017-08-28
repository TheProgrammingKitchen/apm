defmodule TreeTest do
  use ExUnit.Case
  doctest Tree

  setup _ do
    Tree.drop_all!
    :ok
  end


  test "Tree is removed from registry on exit" do
    {:ok, pid1} = Tree.new_tree("T1")
    {:ok, pid2} = Tree.new_tree("T2")
    assert Tree.lookup("T1") == pid1
    assert Tree.lookup("T2") == pid2

    Process.exit(pid2, :kill)

    assert Tree.lookup("T1") == pid1
    assert Tree.lookup("T2") == :not_found
  end
end
