defmodule Tree.Node do
  defstruct id: nil, data: %{}

  def start_link(args) do
    Agent.start_link fn -> args end
  end

  def id(pid) do
    Agent.get(pid, fn(rec) -> rec.id end)
  end

  def data(pid) do
    Agent.get(pid, fn(rec) -> rec.data end)
  end

end
