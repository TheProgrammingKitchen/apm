defmodule ApmIssuesTest do
  use ExUnit.Case
  doctest ApmIssues.Issue

  setup do
    Application.ensure_all_started(:apm_repository)
    :ok
  end


end
