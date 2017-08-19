defmodule ApmPx.Web.IssuesController do
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
    entity = ApmIssues.Issue.new( Map.merge(options,%{subject: subject}))
  
    ApmIssues.Repo.insert(entity.uuid,entity,parent,[]) 
   
    if parent do
      ApmIssues.Repo.add_child(parent,entity.uuid)
    end
    
    conn 
      |> put_flash(:success, gettext("Issue successfully created"))
      |> redirect(to: "/issues/#{entity.uuid}")
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
    uuid = params["id"]
    ApmIssues.Repo.delete(uuid)
    conn
      |> put_flash(:success, gettext("Issue deleted"))
      |> redirect(to: issues_path(conn, :index))
  end



  ### Private helpers ########################################


  defp cast(params) do
    subject = params["subject"]
    options =  Map.drop(params, ["subject"])
    entity = for {key, val} <- options, into: %{}, do: {String.to_atom(key), val}
    {subject, entity, params["parent_id"]}
  end

end

