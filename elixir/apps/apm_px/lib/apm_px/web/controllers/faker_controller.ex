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
      description_max_len: 128,
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
      |> put_flash(:success, "Fake items successfully created with options (cnt,length,depth,max_children): #{inspect opts}")
      |> redirect(to: issues_path(conn, :index))
  end

  ### Private helpers ########################################

  defp cast(params) do
    {cnt,_} = (params["number_of_roots"] ) |> Integer.parse
    {max_children,_} =  params["number_of_sub_nodes"] |> Integer.parse()
    {depth,_} =  params["depth"] |> Integer.parse()
    {description_max_len,_} =  params["description_max_len"] |> Integer.parse()
    {cnt,description_max_len,depth,max_children}
  end

  defp create_root_issues(opts) when is_tuple(opts) do
    {cnt,_descr_max_len,_depth,_children} = opts
    Enum.each((1..cnt), fn(_) -> register_root_node_with_children(opts) end)
    opts
  end

  defp register_root_node_with_children(opts) do
    {_cnt,description_max_len,depth,max_children} = opts
    with root_uuid <- UUID.uuid1(),
      %ApmIssues.Node{ id: root_uuid, attributes: random_attributes(description_max_len) } 
        |> ApmIssues.register_node,
    do: create_children(root_uuid,depth,max_children,description_max_len)
  end

  defp random_attributes(description_max_len) do
    %{ subject: Faker.Beer.name, description: make_longer_text(description_max_len) }
  end


  defp create_children(parent,0, max_children,description_max_length) do
    children = :rand.uniform(max_children) - 1
    Enum.each( 0..children, fn(_child) ->
      uuid = UUID.uuid1()
      register_fake_node(uuid,parent,description_max_length)
    end)
  end
  defp create_children(parent,max_depth, max_children,description_max_length) do
    m = :rand.uniform(max_children)-1
    Enum.each( 0..m, fn(_child_num) ->
      uuid = UUID.uuid1()
      register_fake_node(uuid,parent,description_max_length)
      depth = :rand.uniform(max_depth)-1
      if depth > 0 do
        create_children(uuid, depth, max_children,description_max_length)
      end
    end)
  end

  defp register_fake_node(uuid,parent,max_length) do
    %ApmIssues.Node{id: uuid, attributes: %{ subject: Faker.Lorem.Shakespeare.hamlet,
        description: make_longer_text(max_length) }}
    |> ApmIssues.register_node( parent )
  end

  defp make_longer_text(max_len) do
    ""
    |> append_random_quotes(&Faker.Lorem.Shakespeare.as_you_like_it/0,max_len) 
    |> append_random_quotes(&Faker.Lorem.Shakespeare.romeo_and_juliet/0,max_len) 
    |> append_random_quotes(&Faker.Lorem.Shakespeare.hamlet/0,max_len) 
    |> append_random_quotes(&Faker.Lorem.Shakespeare.king_richard_iii/0,max_len) 
  end

  defp append_random_quotes(to,from,max_len) do
    num = :rand.uniform(30)
    current_length = String.length(to)
    if current_length < max_len, do: append_text(to, from, num - 1), else: ""
  end

  defp append_text(to, _from, 0), do: to
  defp append_text(to, from, num) do
    (to <> from.() <> " ")
    |> append_text(from, num-1)
  end
end


