defmodule ApmIssues.AdapterTest do
  use ExUnit.Case

  doctest ApmIssues.Adapter.File

  @fixture_file Path.expand("../../../data/fixtures/issues.json", __DIR__)

  test "Fixture file exists" do
    File.exists?(@fixture_file)
  end

  test "Read Items from file" do
    ApmIssues.Adapter.File.read!(@fixture_file)
    
    issue = ApmIssues.Repo.get("12345678-1234-1234-1234-123456789abd")
    assert issue == {
      %{
        subject: "Item Number Two With Children", 
        uuid: "12345678-1234-1234-1234-123456789abd"
      }, 
      nil, 
      ["12345678-1234-1234-1234-123456789abe", "12345678-1234-1234-1234-123456789abf"]
    }
  end
 
  test "Read with children" do
    ApmIssues.Adapter.File.read!(@fixture_file)
    {_root,nil,children} = ApmIssues.Repo.get("12345678-1234-1234-1234-123456789abd")
    [son, daughter]  = children

    assert son == "12345678-1234-1234-1234-123456789abe"
    assert daughter == "12345678-1234-1234-1234-123456789abf"
  end
  
end

