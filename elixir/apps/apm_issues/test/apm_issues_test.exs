defmodule ApmIssuesTest do
  use ExUnit.Case
  doctest ApmIssues

  setup _ do
    ApmIssues.Registry.drop!()
    :ok
  end
  test "Registry gets started as application worker" do
    assert ApmIssues.Registry.state() == %{}
  end
end
