defmodule Tree.Bucket do

  use Agent


  def start_link() do
    Agent.start_link( fn() -> %{} end)
  end

  def get(pid) do
    Agent.get(pid, fn(bucket) -> bucket end)
  end

  def get(pid, key) do
    Agent.get(pid, fn(bucket) ->
      Map.get(bucket, key)
    end)
  end

  def add(pid, key, value) do
    Agent.update(pid, fn(bucket) ->
      Map.put(bucket, key, value)
    end)
  end

end
