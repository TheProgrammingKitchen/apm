defmodule ApmPx.IssueControllerTest do
  require Logger
  use ApmPx.Web.ConnCase
  use TestHelper

  setup do
    ApmIssues.drop!()
    ApmIssues.seed()
    :ok
  end

  test "GET /issues lists all issues", %{conn: conn} do
    session = conn 
              |> login_as("some user", "admin") 
              |> get( "/issues" )
    assert html_response(session, 200) =~ "Item Number One"
    assert html_response(session, 200) =~ "Item Number Two With Children"
    assert html_response(session, 200) =~ "The Son Of #2"
    assert html_response(session, 200) =~ "The Daughter Of #2"
  end

  test "GET /issues when not logged in shows error", %{conn: conn} do
    conn = get conn, "/issues"
    assert html_response(conn, 200) =~ "Please login first"
  end

  test "GET /issues/item-2 renderes only item-2 with children", %{conn: conn} do
    session = conn 
              |> login_as("some user", "admin") 
              |> get( "/issues/12345678-1234-1234-1234-123456789abd" )
    assert html_response(session, 200) =~ "Item Number Two With Children"
    assert html_response(session, 200) =~ "Son Of #2"
    assert html_response(session, 200) =~ "Daughter Of #2"
    refute html_response(session, 200) =~ "Item Number One"
  end

  test "GET /issues/new renders 'new issue form'", %{conn: conn} do
    session = conn 
              |> login_as("some user", "admin") 
              |> get( "/issues/new" )
    assert html_response(session, 200) =~ "Create New Issue"
    assert html_response(session, 200) =~ "Subject"
    assert html_response(session, 200) =~ "Description"
    assert html_response(session, 200) =~ "Submit"
  end

  test "POST /issues creates a new issue", %{conn: conn} do
    conn 
    |> login_as("some user", "admin") 
    |> post( "/issues", 
             %{issue: %{ subject: "New Issue", description: "Some text"}} 
           )

    {uuid, {issue, parent, children}} = ApmIssues.Repo.find_by_subject("New Issue") |> hd
    assert String.match?(uuid, ~r/^[0-9a-f]{8}-/)
    assert issue.subject == "New Issue"
    assert issue.description == "Some text"
    assert children == []
    assert parent == nil
  end

  test "POST /issues/:id updates an existing issue", %{conn: conn} do
    conn 
      |> login_as("some user", "admin") 
      |> post( "/issues", 
               %{issue: %{ subject: "Issue123", description: "Original text"}} 
             )
      {uuid, {_data, _parent, _children}} = (ApmIssues.Repo.find_by_subject("Issue123")) |> hd
 
      conn 
        |> login_as("some user", "admin") 
        |> post( "/issues/#{uuid}", 
                 %{issue: %{ subject: "Issue123", description: "Modified text"}} 
               )

      {uuid, {entity,_parent,_children}} = ApmIssues.Repo.find_by_subject("Issue123") |> hd
 
      assert String.match?(uuid, ~r/^[0-9a-f]{8}-/)
      assert entity.subject == "Issue123"
      assert entity.description == "Modified text"
  end

  test "DELETE /issues/:id deletes an issue and its children", %{conn: conn} do
    {uuid, {_issue, _parent_id, children}} = (ApmIssues.Repo.find_by_subject("Item Number Two With Children")) |> hd
    assert uuid == "12345678-1234-1234-1234-123456789abd"
    assert Enum.count(children) == 2
    cnt = ApmIssues.Repo.count 

    conn
      |> delete( "/issues/#{uuid}" )

    assert ApmIssues.Repo.get(uuid) == :not_found
    assert ApmIssues.Repo.count == cnt - 3
  end

  test "GET /issues/:parent_id/new renders the form with parent field", %{conn: conn} do
    {uuid, _} = ApmIssues.Repo.find_by_subject("Item Number Two With Children") |> hd
    
    session = conn 
              |> login_as("some user", "admin") 
              |> get( ApmPx.Web.Router.Helpers.new_child_path(conn,:new, uuid) )
    
    assert html_response(session, 200) =~ "Add Sub Item for Item Number Two With Children"
  end

  test "POST /issues/ with parent_id creates a new child", %{conn: conn} do
    {_issue, _parent, children } = ApmIssues.Repo.get("12345678-1234-1234-1234-123456789abd")
    before_count = Enum.count(children)

    conn 
    |> login_as("some user", "admin") 
    |> post( "/issues", 
             %{issue: %{parent_id: "12345678-1234-1234-1234-123456789abd", subject: "Sub Issue", description: "New Child"}} 
           )

    {_issue,_parent,children_after} = ApmIssues.Repo.get("12345678-1234-1234-1234-123456789abd") 
    assert children_after |> Enum.count  == before_count + 1
  end

end
