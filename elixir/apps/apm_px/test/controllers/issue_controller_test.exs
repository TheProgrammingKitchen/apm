defmodule ApmPx.IssueControllerTest do
  require Logger
  use ApmPx.ConnCase
  use TestHelper

  setup do
    Application.ensure_all_started(:apm_repository)
    ApmIssues.Repository.drop!()
    ApmIssues.Repository.seed()
    :ok
  end

  test "GET /issues lists all issues", %{conn: conn} do
    session = conn 
              |> login_as("some user", "admin") 
              |> get( "/issues" )
    assert html_response(session, 200) =~ "Item-1"
    assert html_response(session, 200) =~ "Item-2"
  end

  test "GET /issues when not logged in shows error", %{conn: conn} do
    conn = get conn, "/issues"
    assert html_response(conn, 200) =~ "Please login first"
  end

  test "GET /issues/item-2 renderes only item-2 with children", %{conn: conn} do
    session = conn 
              |> login_as("some user", "admin") 
              |> get( "/issues/12345678-1234-1234-1234-123456789ab2" )
    assert html_response(session, 200) =~ "Item-2"
    assert html_response(session, 200) =~ "Item-2.1"
    assert html_response(session, 200) =~ "Item-2.2"
    refute html_response(session, 200) =~ "Item-1"
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

    issue = ApmIssues.Repository.find_by_subject("New Issue") |> hd
    assert String.match?(ApmIssues.Issue.state(issue).id, ~r/^[0-9a-f]{8}-/)
    assert ApmIssues.Issue.state(issue).subject == "New Issue"
    assert ApmIssues.Issue.state(issue).options == %{"description" => "Some text"}
  end

  test "POST /issues/:id updates an existing issue", %{conn: conn} do
    conn 
      |> login_as("some user", "admin") 
      |> post( "/issues", 
               %{issue: %{ subject: "Issue123", description: "Original text"}} 
             )
    {_pid, id} = (ApmIssues.Repository.find_by_subject("Issue123")) |> hd

    conn 
      |> login_as("some user", "admin") 
      |> post( "/issues/#{id}", 
               %{issue: %{ subject: "Issue123", description: "Modified text"}} 
             )
    issue = ApmIssues.Repository.find_by_subject("Issue123") |> hd

    assert String.match?(ApmIssues.Issue.state(issue).id, ~r/^[0-9a-f]{8}-/)
    assert ApmIssues.Issue.state(issue).subject == "Issue123"
    assert ApmIssues.Issue.state(issue).options == %{"description" => "Modified text"}
  end

  test "DELETE /issues/:id deletes an issue and its children", %{conn: conn} do
    ApmIssues.Repository.drop!()
    ApmIssues.Repository.seed()
    {pid, id} = (ApmIssues.Repository.find_by_subject("Item-2")) |> hd
    assert id == "12345678-1234-1234-1234-123456789ab2"
    children = ApmIssues.Issue.children(pid)
    assert Enum.count(children) == 2
    cnt = ApmIssues.Repository.count

    conn
      |> delete( "/issues/#{id}" )

    assert ApmIssues.Repository.find_by_id(id) == :not_found
    assert ApmIssues.Repository.count == cnt - 3
  end

  test "GET /issues/:parent_id/new renders the form with parent field", %{conn: conn} do
    ApmIssues.Repository.drop!()
    ApmIssues.Repository.seed()
    {_pid, parent_id} = (ApmIssues.Repository.find_by_subject("Item-2")) |> hd
    
    session = conn 
              |> login_as("some user", "admin") 
              |> get( ApmPx.Router.Helpers.new_child_path(conn,:new, parent_id) )

    assert html_response(session, 200) =~ "Add Sub Item for Item-2"
  end

  test "POST /issues/ with parent_id creates a new child", %{conn: conn} do
    parent = ApmIssues.Repository.find_by_id("12345678-1234-1234-1234-123456789ab2")
             |> ApmIssues.Issue.state
    before_count = Enum.count(parent.children)

    conn 
    |> login_as("some user", "admin") 
    |> post( "/issues", 
             %{issue: %{parent_id: "12345678-1234-1234-1234-123456789ab2", subject: "Sub Issue", description: "New Child"}} 
           )

    issue = ApmIssues.Repository.find_by_id("12345678-1234-1234-1234-123456789ab2") 
    assert ApmIssues.Issue.state(issue).children |> Enum.count  == before_count + 1
  end

end
