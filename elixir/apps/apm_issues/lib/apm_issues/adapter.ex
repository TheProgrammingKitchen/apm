defmodule ApmIssues.Adapter do
  @moduledoc"""
    The adapter reads ApmIssues.Issue entries from
    a JSON-fixture file into the repository

    For now it's sufficient to define a File-adpter.
    See `ApmIssues.Adapter.File`

    The Adapter is reponsible to load issues from somewhere
    and push it to the Repository.
    > FIXME: This should become a Protocol!
  """

  @doc"""
  Issues is a list of structures going to be pushed to the
  repository. The function returns a list of PIDs.
  """
  def push issues do
    push_with_children(issues)
  end

  defp push_with_children([]), do: nil

  defp push_with_children([issue|rest]) do
    %{ parent_id: nil, children: [] }
    |> Map.merge(issue)
    |> extract_tree_structure
    |> add_to_bucket
    push_with_children(rest)
  end

  defp extract_tree_structure( issue ) do
    %{ parent_id: parent_id, children: children } = issue
    data = Map.drop(issue, [:parent_id, :children])
    {issue.uuid, data, parent_id, children }
  end

  defp add_to_bucket( { uuid, data, parent_id, children } ) do
    ApmIssues.Repo.insert( uuid, data, parent_id, children )
  end
end
