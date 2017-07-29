defmodule ApmPx.IssuesView do
  use ApmPx.Web, :view
  require Logger
  
  alias ApmIssues.{Repository}

  @doc"""
  Render all root-issues recursively
  """
  def render_issues_index(_conn) do
    Repository.root_issues
    |> Enum.map( fn(pid) -> render_issue(pid) end)
  end
  defp render_issue({pid, id}) do
    issue = ApmIssues.Issue.state({pid, id})
    render("_issue_index.html", id: id, pid: pid, issue: issue)
  end

  @doc"""
  Render one issue recursively
  """
  def render_show_issue(conn) do
    params = conn.params
    item_id = params["id"]
    pid = Repository.find_by_id(item_id)
    issue = ApmIssues.Issue.state({pid, item_id})

    render("_issue_index.html", id: item_id, pid: pid, issue: issue)
  end

  @doc"""
  Render one issue recursively
  """
  def render_edit_issue(conn) do
    params = conn.params
    item_id = params["id"]
    pid = Repository.find_by_id(item_id)
    issue = ApmIssues.Issue.state({pid, item_id})
    form(conn, {:update, issue })
  end


  @doc"""
  Render children of an issue recursively
  """
  def render_children(parent_pid) do
    ApmIssues.Issue.children(parent_pid)
    |> Enum.map( fn(pid) -> render_issue(pid) end)
  end

  @doc"""
  Render HTML-Form for issue.
  Default to POST new issue (create).
  """
  def form(conn,{action, changeset} \\ {:create, %ApmIssues.Issue{}} ) do
    path = case action do
      :update -> issues_path(conn, :update, changeset.id)
      :create -> issues_path(conn, :create)
      _ -> Logger.error "Action #{action} not supported"
    end
      
    render("_form.html", conn: conn, issue: changeset, path: path)
  end

  @doc "Format subject"
  def subject(issue) do
    issue.subject || ""
  end

  @doc "Format description"
  def description(issue) do
    issue.options["description"] || ""
  end

end
