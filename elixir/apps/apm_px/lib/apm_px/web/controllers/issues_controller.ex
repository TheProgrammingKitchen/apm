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
    entity = %ApmIssues.Node{ id: UUID.uuid1(), attributes: Map.merge(options,%{subject: subject}) }
    ApmIssues.update(params["id"], entity.attributes)
    conn 
      |> put_flash(:success, gettext("Issue successfully updated"))
      |> redirect(to: "/issues/#{params['id']}")
  end

  @doc """
  Deleat an issue and its children
  """
  def delete(conn, params) do
    id = params["id"]
    ApmIssues.drop!(id)
    conn
      |> put_flash(:success, gettext("Issue deleted"))
      |> redirect(to: issues_path(conn, :index))
  end


  def new_fake(conn,_params) do
    render conn, "fake.html", 
      path: fake_path(conn, :fake), 
      number_of_roots: 3, 
      number_of_sub_nodes: 3, 
      depth: 3
  end

  def fake(conn, params) do
    ApmIssues.Registry.drop!

    {cnt,_} = (params["fake"]["number_of_roots"] ) |> Integer.parse
    {max_children,_} =  params["fake"]["number_of_sub_nodes"] |> Integer.parse()
    {depth,_} =  params["fake"]["depth"] |> Integer.parse()

    Enum.each( (1..cnt), fn(_n) ->
      root_uuid = UUID.uuid1()
      %ApmIssues.Node{ id: root_uuid, attributes: %{ subject: Faker.Beer.name,
        description: make_longer_text() }}
      |> ApmIssues.register_node

      if max_children > 0, do: create_children(root_uuid,depth,max_children)
    end)

    conn
      |> put_flash(:success, "#{cnt} Fake Root Items created with max #{max_children} children per node and a depth of #{depth}")
      |> redirect(to: issues_path(conn, :index))
  end

  defp create_children(parent,0, max_children) do
    children = :rand.uniform(max_children) - 1
    Enum.each( 0..children, fn(_child) ->
      uuid = UUID.uuid1()
      register_fake_node(uuid,parent)
    end)
  end
  defp create_children(parent,max_depth, max_children) do
    m = :rand.uniform(max_children)-1
    Enum.each( 0..m, fn(_child_num) ->
      uuid = UUID.uuid1()
      register_fake_node(uuid,parent)
      depth = :rand.uniform(max_depth)-1
      if depth > 0 do
        create_children(uuid, depth, max_children)
      end
    end)
  end
  defp register_fake_node(uuid,parent) do
    %ApmIssues.Node{id: uuid, attributes: %{ subject: Faker.Lorem.Shakespeare.hamlet,
        description: make_longer_text() }}
    |> ApmIssues.register_node( parent )
  end
  defp make_longer_text do
    ""
    |> append_random_quotes(&Faker.Lorem.Shakespeare.as_you_like_it/0) 
    |> append_random_quotes(&Faker.Lorem.Shakespeare.romeo_and_juliet/0) 
    |> append_random_quotes(&Faker.Lorem.Shakespeare.hamlet/0) 
    |> append_random_quotes(&Faker.Lorem.Shakespeare.king_richard_iii/0) 
  end
  defp append_random_quotes(to,from) do
    num = :rand.uniform(30)
    append_text(to, from, num - 1)
  end
  defp append_text(to, _from, 0), do: to
  defp append_text(to, from, num) do
    (to <> from.() <> " ")
    |> append_text(from, num-1)
  end
  
  ### Private helpers ########################################


  defp cast(params) do
    subject = params["subject"]
    options =  Map.drop(params, ["subject"])
    entity = for {key, val} <- options, into: %{}, do: {String.to_atom(key), val}
    {subject, entity, params["parent_id"]}
  end

end

