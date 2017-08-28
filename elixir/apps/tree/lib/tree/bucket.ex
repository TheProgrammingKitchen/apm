defmodule Tree.Bucket do

  use Agent


  def start_link() do
    Agent.start_link( fn() -> %{} end)
  end

end
