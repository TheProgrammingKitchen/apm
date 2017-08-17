defmodule ApmIssues.Issue do
  @moduledoc """
    `ApmIssue` is a struct representing a (eg Jira)Issue.
    A story, task, bug, ...
  """

  @doc"""
    `uuid` will be generated at `new` using an external
    library. 
    See [RFC 4122](http://www.ietf.org/rfc/rfc4122.txt).

    `subject` and `description` are the first fields to due
    further development. Later versions will have (a lot) more
    fields.
  """
  defstruct uuid: "", subject: "", description: ""

  @doc"""
    Initialize `Issue` with UUID

    ### Example:
        iex> issue = ApmIssues.Issue.new(%{ subject: "Get real"})
        iex> issue.subject
        "Get real"
        iex> issue.description
        ""
        iex> issue.uuid |> String.match?( ~r/[0-9a-f]{8}-/i )
        true

  """
  def new(attributes) do
    %ApmIssues.Issue{uuid: gen_uuid()} |> Map.merge(attributes)
  end

  @doc"""
    FIXME: `uuid, subject, options` is still the old structure. 
  """
  def update( uuid, subject, options ) do
    ApmIssues.Repo.update(uuid, subject, options)
  end


  defp gen_uuid do
    UUID.uuid1()
  end

end
