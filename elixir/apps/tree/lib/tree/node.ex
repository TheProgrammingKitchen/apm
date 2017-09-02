defmodule Tree.Node do
  defstruct id: nil, data: %{}, parent_pid: nil

  def start_link(args) do
    Agent.start_link fn -> args end
  end

  def parent(pid) do
    IO.inspect ["GET PARENT",pid]
    %Tree.Node{id: id, parent_pid: parent} = Agent.get( pid, fn(state) ->
      state
    end)
    {id, parent} 
  end

  def id(pid) do
    Agent.get(pid, fn(rec) ->
      rec.id end)
  end

  def data(pid) do
    Agent.get(pid, fn(rec) -> rec.data end)
  end

end
