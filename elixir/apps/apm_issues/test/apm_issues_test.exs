defmodule ApmIssuesTest do
  use ExUnit.Case
  doctest ApmIssues
  doctest ApmIssues.Registry

  # Examples. See defp setup_example
  @node_1 %ApmIssues.Node{id: 1}
  @node_1_1 %ApmIssues.Node{id: 1.1}
  @node_1_2 %ApmIssues.Node{id: 1.2}
  @node_2 %ApmIssues.Node{id: 2}
  @node_2_1 %ApmIssues.Node{id: 2.1}
  @node_2_2 %ApmIssues.Node{id: 2.2}

  setup _ do
    ApmIssues.Registry.drop!()
    :ok
  end

  test "Registry gets started as application worker with no entries" do
    assert ApmIssues.Registry.state() == %{}
  end

  test "register a root node" do
    {:ok, {id,supervisor,data_agent}} = ApmIssues.register_node(@node_1)
    assert id == 1
    assert is_pid(supervisor)
    assert is_pid(data_agent)
  end

  test "register sub node" do
    ApmIssues.register_node(@node_1)
    ApmIssues.register_node(@node_1_1, 1) 
    {id,supervisor,data_agent} = ApmIssues.lookup(1.1)
    assert id == 1.1
    assert is_pid(supervisor)
    assert is_pid(data_agent)
    assert ApmIssues.parent_id(1.1) == 1
  end

  test "children of a node with sub-nodes" do
    setup_example()

    assert [1.1,1.2] == ApmIssues.children_ids(1)
    assert [2.1,2.2] == ApmIssues.children_ids(2)
  end

  test "stopping a sub node removes it from parent and registry" do
    setup_example()

    ApmIssues.drop!(1.1)

    assert [1.2] == ApmIssues.children_ids(1)
    assert [2.1,2.2] == ApmIssues.children_ids(2)
  end

  test "removing a node also removes it's children" do
    setup_example()

    ApmIssues.drop!(1)
    _wait_for_sync = ApmIssues.Registry.state()

    assert :not_found == ApmIssues.lookup(1)
    assert :not_found == ApmIssues.lookup(1.1)
    assert :not_found == ApmIssues.lookup(1.2)
  end

  test "getting the parent-id of a node" do
    setup_example()

    assert 1 == ApmIssues.parent_id(1.1)
    assert 1 == ApmIssues.parent_id(1.2)

    assert 2 == ApmIssues.parent_id(2.1)
    assert 2 == ApmIssues.parent_id(2.2)

    assert :no_parent == ApmIssues.parent_id(2)
    assert :no_parent == ApmIssues.parent_id(1)

    assert :not_found == ApmIssues.parent_id("something not stored")
  end

  test "updating attributes of a node" do
    {:ok, _node} = ApmIssues.register_node( %ApmIssues.Node{id: 1, attributes: %{ foo: :bar}} )
    assert ApmIssues.attributes(1) == %{ foo: :bar }

    ApmIssues.update(1, %{ foo: :baz } )
    assert ApmIssues.attributes(1) == %{ foo: :baz }
  end


  defp setup_example do
    ApmIssues.register_node(@node_1)
    ApmIssues.register_node(@node_1_1, 1) 
    ApmIssues.register_node(@node_1_2, 1) 
    ApmIssues.register_node(@node_2)
    ApmIssues.register_node(@node_2_1, 2) 
    ApmIssues.register_node(@node_2_2, 2) 
  end

end
