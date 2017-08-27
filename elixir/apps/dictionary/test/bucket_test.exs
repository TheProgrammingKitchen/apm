defmodule BucketTest do
  use ExUnit.Case

  @uuid_regex ~r/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\Z/
  doctest Dictionary.Bucket
end
