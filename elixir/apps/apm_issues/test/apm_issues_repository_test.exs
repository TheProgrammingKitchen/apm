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
    pid = Repository.find_by_id("Item-1")
    assert %Issue{id: "Item-1", subject: "Item-1", options: %{}} == Issue.state(pid)
  end

  test "Find not existing issue returns :not_found" do
    assert :not_found = Repository.find_by_id(:nothing_here)
  end



end
