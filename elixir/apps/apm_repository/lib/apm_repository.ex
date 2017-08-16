defmodule ApmRepository do
  @moduledoc """
    Documentation for ApmRepository.
  """

  @doc"""
    Create and register a new bucket inside the dictionary.

    ### Example:

          iex> {:ok, _type, _pid} = ApmRepository.Dictionary.new_bucket({"People", %{}})
          iex> ApmRepository.Dictionary.count
          1
  """
  def new_bucket({name, type}) do
    ApmRepository.Dictionary.new_bucket({name, type})
  end

  @doc"""
    Shutdown the server
  """
  def drop!() do
    ApmRepository.Dictionary.drop!
  end
end
