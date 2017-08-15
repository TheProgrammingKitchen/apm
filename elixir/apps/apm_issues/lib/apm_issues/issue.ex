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

  def update( uuid, subject, options ) do
    ApmIssues.Repo.update(uuid, subject, options)
  end

  @doc"""
  Remove issue with _uuid_ and all it's children (recursively)
  """
  def drop_with_children(uuid,children) do
    ApmIssues.Repo.drop_with_children(uuid,children)
  end

  @doc"""
  Remove child_id from the list of children of parent_id
  """
  def remove_child(parent_id,child_id) do
    ApmIssues.Repo.remove_child(parent_id,child_id)
  end

  defp gen_uuid do
    UUID.uuid1()
  end

end
