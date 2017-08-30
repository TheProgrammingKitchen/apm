defmodule Tree.Node do
  defstruct id: nil, data: %{}

  def id(pid) do
    "MY ID"
  end

  def data(pid) do
    Agent.get(pid, fn(rec) -> rec.data end)
  end

  def start_link(args) do
    Agent.start_link fn -> args end
  end
end
