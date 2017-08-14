defmodule DictionaryTest do
  use ExUnit.Case

  doctest ApmRepository.Dictionary

  alias ApmRepository.{ Bucket, Dictionary }

  setup _ do
    Dictionary.drop!
    {:ok, %{}, bucket} = ApmRepository.new_bucket({"issues", %{}})

    on_exit fn ->
      ApmRepository.drop!
    end

    {:ok, %{bucket: bucket}}
  end

  test "Dictionary registers bucket", %{bucket: _bucket} do
    assert Dictionary.count == 1
  end

  test "Bucket is removed from Dictionary when it exits", %{bucket: bucket} do
    assert Dictionary.count == 1
    GenServer.stop(bucket)
    assert Dictionary.count == 0
  end

  test "two bucket's does not share state", %{bucket: _b} do
    {:ok, %{}, people} = ApmRepository.new_bucket({"people", %{}})
    {:ok, %{}, emails} = ApmRepository.new_bucket({"emails", %{}})

    Bucket.add(people, 1, %{ name: "Andreas" })
    Bucket.add(emails, 1, %{ email: "somewhere@example.com"})

    assert {%{name: "Andreas"}, nil, []} == Bucket.get(people,1)
    assert {%{email: "somewhere@example.com"}, nil, []} == Bucket.get(emails,1)
  end

  test "full tree integration", %{bucket: bucket} do
    issue1  = %{ name: "Bob" }
    issue11 = %{ name: "Bob Jr.1" }
    issue12 = %{ name: "Bob Jr.2" }
    issue2  = %{ name: "Will" }

    Bucket.add(bucket, "ID-BOB", issue1)
    Bucket.add_child(bucket, "ID-BOB", "ID-BOB-A", issue11)
    Bucket.add_child(bucket, "ID-BOB", "ID-BOB-B", issue12)
    Bucket.add(bucket, "ID-WILL", issue2)

    assert 4 == Bucket.count(bucket)

    assert ["ID-BOB-B", "ID-BOB-A"] == Bucket.children(bucket, "ID-BOB")
    assert "ID-BOB" == Bucket.parent(bucket, "ID-BOB-A")

  end
end
