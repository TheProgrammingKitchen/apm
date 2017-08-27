defmodule Dictionary do
  @moduledoc """
  The Dictioniary is responsible to supervise all Buckets in our application.
  It provides this API to create, lookup, and stop Buckets.
  """


  @doc"""
  Start a Bucket registers the new Bucket within the Dictionary.

  ### Example:

      iex> {:ok, pid} = Dictionary.start_bucket("Shopping List")
      iex> is_pid(pid)
      true
  """
  def start_bucket(name) do
    Dictionary.BucketList.start_bucket(name)
  end

  @doc"""
  Lookup a bucket by name returns it's pid.

  ### Example:

      iex> {:ok, pid} = Dictionary.start_bucket("Shopping List")
      iex> {"Shopping List", found} = Dictionary.lookup("Shopping List")
      iex> found == pid
      true
  """
  def lookup(name) do
    Dictionary.BucketList.lookup(name)
  end
  
end
