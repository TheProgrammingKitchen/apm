defmodule Dictionary.Bucket do
  @moduledoc"""
  A Bucket holds a `Map` of `Dictionary.Entry`s. The key for each
  entry is an UUID, the value is any struct implementing the
  `Dictionary.Entry.Protocol`.
  """

  use Agent

  @doc"""
  Start the Bucket
  ### Example:

      iex> {:ok, pid} = Dictionary.Bucket.start_link()
      iex> is_pid(pid)
      true
  """
  def start_link() do
    Agent.start_link( fn() -> %{} end)
  end

  @doc"""
  Add a new entry (creates UUID)
  ### Example:

      iex> {:ok, pid} = Dictionary.Bucket.start_link()
      iex> {uuid, entry} = Dictionary.Bucket.new_entry(pid, %{subject: "Something"})
      iex> String.match?(uuid, @uuid_regex)
      true
      iex> entry
      %{subject: "Something"}
  """
  def new_entry(pid, entry) do
    uuid = UUID.uuid1
    Agent.update(pid, fn(bucket) ->
      Map.put(bucket, uuid, entry)
    end)
    {uuid, entry}
  end

  @doc"""
  Get an entry by it's uuid
  ### Example:

      iex> {:ok, pid} = Dictionary.Bucket.start_link()
      iex> {uuid, _entry} = Dictionary.Bucket.new_entry(pid, %{subject: "Something"})
      iex> Dictionary.Bucket.get(pid, uuid)
      %{subject: "Something"}

  """
  def get(pid, key) do
    Agent.get(pid, fn(bucket) ->
      Map.get(bucket, key, :not_found)
    end)
  end


  @doc"""
  Update an entry
  ### Example:

      iex> {:ok, pid} = Dictionary.Bucket.start_link()
      iex> {uuid, _entry} = Dictionary.Bucket.new_entry(pid, %{subject: "Something"})
      iex> Dictionary.Bucket.update(pid, uuid, %{subject: "Something else"})
      iex> Dictionary.Bucket.get(pid, uuid)
      %{subject: "Something else"}
  """
  def update(pid, key, changeset) do
    old = get(pid,key)
    Agent.update(pid,fn(entries) ->
      Map.put(entries, key, Map.merge(old,changeset))
    end)
  end

end
