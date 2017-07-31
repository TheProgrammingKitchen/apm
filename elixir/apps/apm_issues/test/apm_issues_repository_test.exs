defmodule ApmIssuesRepositoryTest do
  use ExUnit.Case
  doctest ApmIssues.Repository
  alias ApmIssues.{Repository, Issue}

  setup do
    Application.ensure_all_started(:apm_repository)
    Repository.drop!
    Repository.seed
    :ok
  end

  test "Issues Repository gets started with the app" do
    assert 4 == ApmIssues.Repository.count() 
  end

  test "Find issues by id" do
    id = "12345678-1234-1234-1234-123456789ab1"
    pid = Repository.find_by_id(id)
    assert %Issue{id: id, subject: "Item-1", options: %{}} == Issue.state(pid)
  end

  test "Find not existing issue returns :not_found" do
    assert :not_found = Repository.find_by_id(:nothing_here)
  end



end
