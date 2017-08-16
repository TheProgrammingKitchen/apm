defmodule ApmPx.IssuesView do
  use ApmPx.Web, :view
  require Logger
  
  alias ApmIssues.{Repo}

  @doc"""
  Render all root-issues recursively
  """
  def render_issues_index(conn) do
    Repo.root_issues
    |> Enum.map( fn(issue) -> render_issue(conn,issue) end)
  end

  defp render_issue(conn,issue) do
    case issue do 
      {uuid, {issue, parent, children}} ->
          render("_issue_index.html", 
            conn: conn, id: uuid, parent_id: parent, 
            issue: issue, children: children
          )
      {uuid, :not_found} -> "Issue #{uuid} not found"
    end
  end

  @doc"""
  Render one issue recursively
  """
  def render_show_issue(conn) do
    params = conn.params
    item_id = params["id"]
    case Repo.get(item_id) do
      :not_found -> "Issue #{item_id} not found"
      {entity, parent, children} -> render(
        "_issue_index.html", conn: conn, id: item_id, issue: entity,
        parent_id: parent, children: children
      )
    end
  end

  @doc"""
  Render one issue for editing
  """
  def render_edit_issue(conn) do
    params = conn.params
    item_id = params["id"]
    {issue, _parent_id, _children} = Repo.get(item_id)
    form(conn, {:update, issue })
  end


  @doc"""
  Render children of an issue recursively
  """
  def render_children(conn,children) do
    children
    |> Enum.map( fn(child_id) -> 
      child = ApmIssues.Repo.get(child_id)
      render_issue(conn,{child_id, child}) 
    end)
  end

  @doc"""
  Render HTML-Form for issue.
  Default to POST new issue (create).
  """
  def form(conn,{action, changeset} \\ {:create, %ApmIssues.Issue{}} ) do
    path = case action do
      :update -> issues_path(conn, :update, changeset.uuid)
      :create -> issues_path(conn, :create)
      _ -> Logger.error "Action #{action} not supported"
    end
      
    render("_form.html", conn: conn, issue: changeset, path: path)
  end

  @doc "Format subject"
  def subject(issue) do
    issue.subject || ""
  end

  @doc "Format id"
  def id(issue) do
    issue.uuid || ""
  end

  @doc "Format description"
  def description(issue) do
    Map.merge(%{description: ""},issue).description
  end

  def description(issue, :markdown) do
    description(issue)
      |> Earmark.as_html!
      |> raw
  end

  @doc "Get title of a given id"
  def subject_for_id(uuid) do
    {issue, parent_id, children} = ApmIssues.Repo.get(uuid)
    issue.subject
  end

end
