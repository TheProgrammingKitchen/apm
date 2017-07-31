defmodule ApmIssues.AdapterTest do
  use ExUnit.Case

  doctest ApmIssues.Adapter.File

  @fixture_file Path.expand("../../../data/fixtures/issues.json", __DIR__)

  test "Fixture file exists" do
    File.exists?(@fixture_file)
  end

  test "Read Items from file" do
    [first,_] = ApmIssues.Adapter.File.read!(@fixture_file)
    assert ApmIssues.Issue.state(first).id == "12345678-1234-1234-1234-123456789ab1"
    assert ApmIssues.Issue.state(first).subject == "Item-1"
  end

  test "Read with children" do
    [_first,second] = ApmIssues.Adapter.File.read!(@fixture_file)
    [daughter,son]  = ApmIssues.Issue.children(second)

    assert ApmIssues.Issue.state(son).id == "12345678-1234-1234-1234-123456789a21"
    assert ApmIssues.Issue.state(daughter).id == "12345678-1234-1234-1234-123456789a22"
  end

  test "Read into repository" do
    ApmIssues.Adapter.File.read!(@fixture_file)
    |> ApmIssues.Adapter.push

    pid = ApmIssues.Repository.find_by_id("12345678-1234-1234-1234-123456789ab1")
    assert ApmIssues.Issue.state(pid).id == "12345678-1234-1234-1234-123456789ab1"
    assert ApmIssues.Issue.state(pid).subject == "Item-1"
  end
end

