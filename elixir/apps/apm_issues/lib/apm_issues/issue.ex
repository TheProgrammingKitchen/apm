defmodule ApmIssues.Issue do
  @moduledoc """
  `ApmIssue` is a struct representing a (eg Jira)Issue.
  A story, task, bug, ...
  """

  defstruct uuid: "", subject: "", description: ""

  @doc"""
    Initializing with UUID

    ### Example:
        iex> issue = ApmIssues.Issue.new(%{ subject: "Get real"})
        iex> issue.subject
        "Get real"
        iex> issue.uuid |> String.match?( ~r/[0-9a-f]{8}-/i )
        true

  """
  def new(attributes) do
    %ApmIssues.Issue{uuid: gen_uuid()} |> Map.merge(attributes)
  end

  defp gen_uuid do
    UUID.uuid1()
  end

end
