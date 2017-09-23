defmodule ApmPx.IssueControllerTest do
  require Logger
  use ApmPx.Web.ConnCase
  use TestHelper

  setup do
    ApmIssues.Registry.drop!()
    ApmPx.Fixtures.read()
    |> ApmIssues.seed()
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

    {issue, _sup, _data} = ApmIssues.find_by(:subject, "New Issue") 
    assert String.match?(issue, ~r/^[0-9a-f]{8}-/)
    assert ApmIssues.attributes(issue).subject == "New Issue"
    assert ApmIssues.attributes(issue).description == "Some text"
    assert ApmIssues.children_ids(issue) == []
    assert ApmIssues.parent_id(issue) == :no_parent
  end

  test "POST /issues/:id updates an existing issue", %{conn: conn} do
    conn 
      |> login_as("some user", "admin") 
      |> post( "/issues", 
               %{issue: %{ subject: "Issue123", description: "Original text"}} 
             )
      {id, _sup, _data} = (ApmIssues.find_by(:subject, "Issue123")) 
 
      conn 
        |> login_as("some user", "admin") 
        |> post( "/issues/#{id}", 
                 %{issue: %{ subject: "Issue123", description: "Modified text"}} 
               )

      {entity,_sup,_data} = ApmIssues.find_by(:subject, "Issue123") 
 
      assert String.match?(entity, ~r/^[0-9a-f]{8}-/)
      assert ApmIssues.attributes(entity).subject == "Issue123"
      assert ApmIssues.attributes(entity).description == "Modified text"
  end

  test "DELETE /issues/:id deletes an issue and its children", %{conn: conn} do
    conn 
      |> login_as("some user", "admin") 
      |> get( "/issues" )


    {id, _sup, _data} =  ApmIssues.find_by(:subject, "Item Number Two With Children")
    assert id == "12345678-1234-1234-1234-123456789abd"
    assert 2 == ApmIssues.children_ids(id) |> Enum.count
    cnt = ApmIssues.Registry.state() |> Map.keys |> Enum.count

    conn
      |> delete( "/issues/#{id}" )

    Process.sleep(500)

    cnt_after = ApmIssues.Registry.state() |> Map.keys |> Enum.count
    assert cnt - 3 == cnt_after

    assert :not_found == ApmIssues.lookup(id)

  end

  test "GET /issues/:parent_id/new renders the form with parent field", %{conn: conn} do
    {id,_sup, _dat} = ApmIssues.find_by(:subject, "Item Number Two With Children") 
    
    session = conn 
              |> login_as("some user", "admin") 
              |> get( ApmPx.Web.Router.Helpers.new_child_path(conn,:new, id) )
    
    assert html_response(session, 200) =~ "Add Sub Item for Item Number Two With Children"
  end

  test "POST /issues/ with parent_id creates a new child", %{conn: conn} do
    {_id, _sup, _data } = ApmIssues.lookup("12345678-1234-1234-1234-123456789abd")
    before_count = ApmIssues.Registry.state() |> Map.keys |> Enum.count

    conn 
    |> login_as("some user", "admin") 
    |> post( "/issues", 
             %{issue: %{parent_id: "12345678-1234-1234-1234-123456789abd", subject: "Sub Issue", description: "New Child"}} 
           )

    {_id,_sup,_data} = ApmIssues.lookup("12345678-1234-1234-1234-123456789abd") 
    count_after = ApmIssues.Registry.state() |> Map.keys |> Enum.count
    assert before_count + 1 == count_after
  end

  test "GET /issues/fake renders error if not logged in", %{conn: conn} do
    session = 
      conn |> get( "/issues/fake" )
    assert html_response(session, 200) =~ "Please login first"
    refute html_response(session, 200) =~ "Number of sub nodes per root"
    refute html_response(session, 200) =~ "Depth of sub nodes"
  end

  test "GET /issues/fake renders the fake-form", %{conn: conn} do
    session = 
      conn
      |> login_as("some user", "admin")
      |> get( "/issues/fake" )

    assert html_response(session, 200) =~ "Number of root nodes"
    assert html_response(session, 200) =~ "Number of sub nodes per root"
    assert html_response(session, 200) =~ "Depth of sub nodes"
  end

  test "POST /issues/fake creates faker entries based on _fake_form.", %{conn: conn} do
    ApmIssues.Registry.drop!
    conn
    |> login_as("Admin", "admin")
    |> post( "/issues/fake", %{ "fake" => %{ "number_of_roots" => "3", "number_of_sub_nodes" => "3", "depth" => "3" }})

    assert ApmIssues.Registry.state |> Map.keys |> Enum.count >= 3
  end

end
