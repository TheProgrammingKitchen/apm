defmodule ApmPx.IssuesController do
  require Logger

  @moduledoc """
  Routes handled by this controller

      - GET `/issues` index.html
      - GET `/issues/new` new.html
      - GET `/issues/:id` show.html
      - POST `/issues`    create & redirect to show new issue
      - PUT  `/issues/:id` update & redirect to show modified issue

  """

  use ApmPx.Web, :controller

  @doc """
  The Issues index page
  """
  def index(conn, _params) do
    render conn, "index.html"
  end

  @doc """
  Show one issue with children
  """
  def show(conn, _params) do
    render conn, "show.html"
  end

  @doc """
  Show form for new Issue & submit to `POST /issues`
  """
  def new(conn, params) do
    render conn, "new.html", parent_id: params["id"]
  end
  
  @doc """
  POST /issues Creates a new issue
  """
  def create(conn, params) do
    {subject,options,parent} = cast(params["issue"])
    pid = ApmIssues.Issue.create( subject, Map.drop(options,["parent_id"]) )
    id  = pid |> ApmIssues.Issue.id()

    if parent do
      {parent_pid,_parent_id} = ApmIssues.Repository.find_by_id(parent)
      ApmIssues.Issue.add_child(parent_pid,pid)
    end

    conn 
      |> put_flash(:success, gettext("Issue successfully created"))
      |> redirect(to: "/issues/#{id}")
  end

  @doc """
  Edit an issue
  """
  def edit(conn, _params) do
    render conn, "edit.html"
  end

  @doc """
  Update issue
  """
  def update(conn, params) do
    {subject,options,_parent_id} = cast(params["issue"])
    ApmIssues.Issue.update( params["id"], subject, options )
    conn 
      |> put_flash(:success, gettext("Issue successfully updated"))
      |> redirect(to: "/issues/#{params['id']}")
  end

  @doc """
  Deleat an issue and its children
  """
  def delete(conn, params) do
    {pid, _id} = ApmIssues.Repository.find_by_id(params["id"])
    ApmIssues.Issue.drop_with_children(pid)
    conn
      |> put_flash(:success, gettext("Issue deleted"))
      |> redirect(to: issues_path(conn, :index))
  end



  ### Private helpers ########################################


  defp cast(params) do
    subject = params["subject"]
    options =  Map.drop(params, ["subject"])
    {subject, options, params["parent_id"]}
  end

end

