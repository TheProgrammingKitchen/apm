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
  def new(conn, _params) do
    render conn, "new.html"
  end
  
  @doc """
  POST /issues Creates a new issue
  """
  def create(conn, params) do
    {id,subject,options} = cast(params["issue"])
    ApmIssues.Issue.new( id, subject, options )
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
    {id,subject,options} = cast(params["issue"])
    ApmIssues.Issue.update( id, subject, options )
    conn 
      |> put_flash(:success, gettext("Issue successfully updated"))
      |> redirect(to: "/issues/#{id}")
  end



  ### Private helpers ########################################


  defp cast(params) do
    subject = params["subject"]
    id = make_id(subject)
    options = Map.drop(params, ["subject"])
    {id, subject, options}
  end

  defp make_id(string) do
    string
    |> String.replace(" ","-")
  end
end

