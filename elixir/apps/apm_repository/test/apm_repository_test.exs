defmodule ApmRepositoryTest do
  use ExUnit.Case

  doctest ApmRepository

  alias ApmRepository.{ Bucket }

  defmodule ExampleStruct do
    defstruct uuid: "", subject: "", description: ""
  end

  # Clear dictionaries before and after tests
  setup _ do
    ApmRepository.drop!
    on_exit fn ->
      ApmRepository.drop!
    end
  end

  test "Simple usage of `ApmRepository`" do

    # Start a Bucket
    {:ok, ApmRepositoryTest.ExampleStruct, bucket} =
      ApmRepository.new_bucket({"issues", ExampleStruct})

    assert is_pid(bucket)

    # Add a to the bucket
    Bucket.add( bucket,"UUID-123", %{ key1: "Value1", key2: "Value2" } )
    {entity,_parent,_children} = Bucket.get(bucket, "UUID-123")
    assert "Value1" == entity.key1
    assert "Value2" == entity.key2

    # Update an existing entry
    :ok = Bucket.update(bucket, "UUID-123", %{ key2: "Modified"})
    
    expected = {%{key1: "Value1", key2: "Modified"}, nil, []}
    current = Bucket.get(bucket, "UUID-123")
    assert current == expected

    # Remove entry
    Bucket.remove(bucket, "UUID-123")
    current = Bucket.get(bucket, "UUID-123")
    assert nil == current 

    
  end

  test "Shutdown an Entry removes it from the dictionary" do
    # Start a Bucket
    {:ok, ApmRepositoryTest.ExampleStruct, bucket1} =
      ApmRepository.new_bucket({"issues", ExampleStruct})
    # Start another Bucket
    {:ok, ApmRepositoryTest.ExampleStruct, bucket2} =
      ApmRepository.new_bucket({"people", ExampleStruct})

    Bucket.add( bucket1,"1", %{ subject: "Subject 1"})
    Bucket.add( bucket2,"1", %{ subject: "Subject 1"})
    Bucket.add( bucket2,"2", %{ subject: "Subject 2"})

    assert 1 == ApmRepository.Bucket.count(bucket1)
    assert 2 == ApmRepository.Bucket.count(bucket2)

    Bucket.remove( bucket2, "1" )
    assert 1 == ApmRepository.Bucket.count(bucket2)
  end
end
