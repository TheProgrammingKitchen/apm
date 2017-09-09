defmodule ApmPx.Web.IssuesController do
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
    entity = %ApmIssues.Node{ id: UUID.uuid1(), attributes: Map.merge(options,%{subject: subject}) }
   
    if parent do
      ApmIssues.register_node( entity, parent )
    else
      ApmIssues.register_node(entity)
    end

    conn 
      |> put_flash(:success, gettext("Issue successfully created"))
      |> redirect(to: "/issues/#{entity.id}")
  end

  @doc """
  Edit an issue
  """
  def edit(conn, params) do
    render conn, "edit.html", changeset: ApmIssues.lookup(params["id"])
  end

  @doc """
  Update issue
  """
  def update(conn, params) do
    {subject,options,_parent} = cast(params["issue"])
    ApmIssues.update(params["id"], Map.merge(options,%{subject: subject}) )
    conn 
      |> put_flash(:success, gettext("Issue successfully updated"))
      |> redirect(to: "/issues/#{params['id']}")
  end

  @doc """
  Deleat an issue and its children
  """
  def delete(conn, params) do
    ApmIssues.drop!(params["id"])
    conn
      |> put_flash(:success, gettext("Issue deleted"))
      |> redirect(to: issues_path(conn, :index))
  end
  
  ### Private helpers ########################################

  # Get values out of params 
  # FIXME: Should be more direct, Left overs from old behaviour
  defp cast(params) do
    subject = params["subject"]
    options =  Map.drop(params, ["subject"])
    entity = options |> with_atom_keys 
    {subject, entity, params["parent_id"]}
  end

  defp with_atom_keys(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end
end

