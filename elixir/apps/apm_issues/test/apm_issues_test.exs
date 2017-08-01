defmodule ApmIssuesTest do
  use ExUnit.Case
  doctest ApmIssues.Issue

  setup do
    Application.ensure_all_started(:apm_repository)
    :ok
  end


  test "Creating an Issue without ID generates a UUID" do
    id = ApmIssues.Issue.create("Subject only", %{ description: "Called new without ID"})
    |> ApmIssues.Issue.id()

    # Format fedd7d04-761f-11e7-af40-8c85901a6abc
    regex = ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

    assert String.match?(id, regex )
  end


end
