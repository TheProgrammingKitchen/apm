defmodule ApmPx.Web.FakerController do
  @moduledoc """
  Creates Test-data randomly
  """

  use ApmPx.Web, :controller

  @doc"""
  Render the option form for Faker
  """
  def new_fake(conn,_params) do
    render conn, "fake.html", 
      path: fake_path(conn, :fake), 
      number_of_roots: 3, 
      number_of_sub_nodes: 3, 
      depth: 3
  end

  @doc"""
  Create Fake Data based on the params posted from `new_fake`
  and return to issues/index.
  """
  def fake(conn, params) do
    ApmIssues.Registry.drop!
    opts = params["fake"] |> cast() |> create_root_issues()

    conn
      |> put_flash(:success, "Fake items successfully created with options (cnt,depth,max_children): #{inspect opts}")
      |> redirect(to: issues_path(conn, :index))
  end

  ### Private helpers ########################################

  defp cast(params) do
    {cnt,_} = (params["number_of_roots"] ) |> Integer.parse
    {max_children,_} =  params["number_of_sub_nodes"] |> Integer.parse()
    {depth,_} =  params["depth"] |> Integer.parse()
    {cnt,depth,max_children}
  end

  defp create_root_issues(opts) when is_tuple(opts) do
    {cnt,_depth,_children} = opts
    Enum.each((1..cnt), fn(_) -> register_root_node_with_children(opts) end)
    opts
  end

  defp register_root_node_with_children(opts) do
    {_cnt,depth,max_children} = opts
    with root_uuid <- UUID.uuid1(),
      %ApmIssues.Node{ id: root_uuid, attributes: random_attributes() } 
        |> ApmIssues.register_node,
    do: create_children(root_uuid,depth,max_children)
  end

  defp random_attributes do
    %{ subject: Faker.Beer.name, description: make_longer_text() }
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
end


