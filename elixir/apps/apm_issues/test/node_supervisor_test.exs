defmodule NodeSupervisorTest do
  use ExUnit.Case
  require Logger
  doctest ApmIssues.Registry

  alias ApmIssues.{Registry, Node}

  setup _ do
    Registry.drop!
    :ok
  end

  test "starting a new root node" do
    {:ok, {id, node_supervisor, node_data_agent}} = 
      %Node{ id: "Node 1", attributes: %{ name: "Root Node" } }
      |> ApmIssues.register_node()

    assert is_pid(node_data_agent)
    assert is_pid(node_supervisor)
    assert "Node 1" == id
  end

  test "nodes are registered" do
    {:ok, node} = 
      %Node{ id: "Node 1", attributes: %{ name: "Root Node" } }
      |> ApmIssues.register_node()

    {id_a, node_supervisor_a, node_data_agent_a} = node
    {id_b, node_supervisor_b, node_data_agent_b} = ApmIssues.lookup("Node 1")

    assert id_a == id_b
    assert node_supervisor_a == node_supervisor_b
    assert node_data_agent_a == node_data_agent_b
  end

  test "lookup for not registered node returns :not_found" do
    assert :not_found == ApmIssues.lookup("Something not registered")
  end

  test "terminated nodes are removed from registry" do
      %Node{ id: "Node 1", attributes: %{ name: "Node ONE" } }
        |> ApmIssues.register_node()
      %Node{ id: "Node 2", attributes: %{ name: "Node TWO" } }
        |> ApmIssues.register_node()

      {n1,_,_} = ApmIssues.lookup("Node 1")
      {n2,_,_} = ApmIssues.lookup("Node 2")

      assert n1 == "Node 1"
      assert n2 == "Node 2"

      ApmIssues.drop!(n1)
  end

end
