defmodule DictionaryTest do
  use ExUnit.Case
  doctest Dictionary


  test "A bucket get's removed from BucketList if it terminates" do
    {:ok, shopping_list} = Dictionary.start_bucket("Shopping List")
    {:ok, todo_list}     = Dictionary.start_bucket("Todo List")

    Process.exit(shopping_list,:kill)

    assert { "Todo List", todo_list } == Dictionary.lookup("Todo List")
    assert :not_found == Dictionary.lookup("Shopping List")
  end
end
