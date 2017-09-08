defmodule ApmPx.Web.IssuesView do
  use ApmPx.Web, :view
  require Logger
  
  @doc"""
  Render all root-issues recursively
  """
  def render_issues_index(conn) do
    ApmIssues.roots
    |> Enum.map( fn(issue) -> render_issue(conn,issue) end)
  end

  defp render_issue(conn,issue) do
    case ApmIssues.lookup(issue) do 
      {uuid, _supervisor, _data} ->
          render("_issue_index.html", 
            conn: conn, id: uuid, parent_id: ApmIssues.parent_id(uuid), 
            issue: ApmIssues.data(issue), children: ApmIssues.children_ids(uuid)
          )
      {uuid, :not_found} -> display_not_found(uuid)
    end
  end

  
  @doc"""
  Render one issue recursively
  """
  def render_show_issue(conn) do
    params = conn.params
    item_id = params["id"]
    case ApmIssues.lookup(item_id) do
      :not_found -> display_not_found(item_id)
      _ -> render(
        "_issue_index.html", conn: conn, id: item_id, issue: ApmIssues.data(item_id),
        parent_id: ApmIssues.parent_id(item_id), children: ApmIssues.children_ids(item_id)
      )
    end
  end

  @doc"""
  Render one issue for editing
  """
  def render_edit_issue(conn) do
    params = conn.params
    item_id = params["id"]
    {issue, _sup, _data} = ApmIssues.lookup(item_id)
    form(conn, {:update, ApmIssues.data(issue) })
  end


  @doc"""
  Render children of an issue recursively
  """
  def render_children(conn,children) do
    children
    |> Enum.map( fn(child_id) -> 
      case ApmIssues.lookup(child_id) do
        :not_found -> display_not_found(child_id)
        _ -> render_issue(conn,child_id) 
      end
    end)
  end

  @doc"""
  Render HTML-Form for issue.
  Default to POST new issue (create).
  """
  def form(conn,{action, changeset} \\ {:create, %ApmIssues.Node{}} ) do
    path = case action do
      :update -> issues_path(conn, :update, changeset.id)
      :create -> issues_path(conn, :create)
      _ -> Logger.error "Action #{action} not supported"
    end
      
    render("_form.html", conn: conn, issue: changeset, path: path)
  end

  @doc "Format subject"
  def subject(issue) do
    case issue.attributes do
      nil  -> ""
      attr -> attr.subject || ""
    end
  end

  @doc "Format parent subject"
  def parent_subject(parent_id) do
    with {issue,_sup,_dat} <- ApmIssues.lookup(parent_id) do
      ApmIssues.data(issue).attributes.subject
    end
  end

  @doc "Format id"
  def id(issue) do
    case issue do
      nil -> ""
      _   -> issue.id 
    end
  end

  @doc "Format description"
  def description(issue) do
    case issue.attributes do
      nil  -> ""
      attr -> Map.merge(%{description: ""},attr).description
    end
  end

  @doc "Render description as markdown `description(issue, :markdown)`"
  def description(issue, :markdown) do
    description(issue)
      |> Earmark.as_html!
      |> raw
  end

  @doc "Get title of a given id"
  def subject_for_id(id) do
    ApmIssues.attributes(id).subject || ""
  end

  defp display_not_found(uuid) do
    raw "<header><p class='alert alert-danger'>Issue <b>#{uuid}</b> not found.</p></header>"
  end

end
