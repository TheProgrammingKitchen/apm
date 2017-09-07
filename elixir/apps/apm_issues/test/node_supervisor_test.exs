defmodule NodeSupervisorTest do
  use ExUnit.Case
  doctest ApmIssues.Node.Supervisor

  alias ApmIssues.{Registry, Node}

  setup _ do
    Registry.drop!
    :ok
  end

  test "starting a new root node" do
    {:ok, {id,node_supervisor,node_data_agent}} = 
    ApmIssues.register_node( %Node{ id: "Node 1", attributes: %{} } )

    assert is_pid(node_data_agent)
    assert is_pid(node_supervisor)
    assert "Node 1" == id
  end

  test "nodes are registered" do
    {:ok, {id,node_supervisor,node_data_agent}} = 
    ApmIssues.register_node( %Node{ id: "Node 1" } )

    assert %{
      "Node 1" => { id, node_supervisor, node_data_agent}
    } ==  ApmIssues.Registry.state()
  end

  test "lookup for not registered node returns :not_found" do
    assert :not_found == ApmIssues.lookup("Something not registered")
  end

  test "terminated nodes are removed from registry" do
    %Node{ id: "Node 1"} |> ApmIssues.register_node()
    %Node{ id: "Node 2"} |> ApmIssues.register_node()
    {"Node 1",_,_} = ApmIssues.lookup("Node 1")
    {"Node 2",_,_} = ApmIssues.lookup("Node 2")

    ApmIssues.drop!("Node 1")
    _sync_state = ApmIssues.Registry.state()

    assert :not_found == ApmIssues.lookup("Node 1")
    {"Node 2",_,_} = ApmIssues.lookup("Node 2")
  end

  test "children of a node are registered" do
    %Node{ id: "Node 1"} |> ApmIssues.register_node()
    %Node{ id: "Node 1.1"} |> ApmIssues.register_node("Node 1")

    {id1, _sup1, _dat1} = ApmIssues.lookup("Node 1")
    assert id1 == "Node 1"

    {id2, _sup2, _dat2} = ApmIssues.lookup("Node 1.1")
    assert id2 == "Node 1.1"
  end

end
