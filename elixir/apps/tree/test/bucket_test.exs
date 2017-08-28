defmodule BucketTest do
  use ExUnit.Case
  doctest Tree.Bucket

  setup _ do
    Tree.drop_all!
    {:ok, pid} = Tree.new_tree("Test Bucket")
    {:ok, %{ bucket: pid}}
  end


  test "New Buckets are empty", %{bucket: bucket} do
    assert Tree.Bucket.get(bucket) == %{} 
  end

  test "Insert something and find it again", %{bucket: bucket} do
    Tree.Bucket.add(bucket, "key", :something )
    assert Tree.Bucket.get(bucket, "key") == :something
  end
end
