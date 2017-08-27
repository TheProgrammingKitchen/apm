defmodule Dictionary.Tree do
  @moduledoc"""
  A Dictionary.Tree maintains relations between parent and children in 
  a `Dictionary.Bucket`
  """

  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end


end
