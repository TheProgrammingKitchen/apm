defmodule Tree do
  @moduledoc """
  TODO: Documentation for Tree.
  """

  @doc """
  State of the tree
  ## Example

      iex> Tree.root_nodes()
      []

  """
  def root_nodes do
    Tree.Registry.state()
  end


  @doc """
  Register new tree
  ## Example

      iex> {:ok, tree} = Tree.new_tree("Project")
      iex> is_pid(tree)
      true
  """
  def new_tree(name) do
    Tree.Registry.new_tree(name)
  end

  @doc"""
  Find the pid of a named tree. Returns :not_found if name
  is not registered.
  ## Example

      iex> {:ok, tree} = Tree.new_tree("Project")
      iex> Tree.lookup("Project") == tree
      true
  """
  def lookup(name) do
    Tree.Registry.lookup(name)
  end

  @doc """
  Empty Registry
  """
  def drop!() do
    Tree.Registry.drop!()
  end

end
