defmodule ApmIssues.Issue do
  @moduledoc"""
  Represents an `Issue` by it's `id` and `attributes`.
  It is used in `ApmIssues.Node.Data`.

      defstruct id: nil, attributes: %{}

  """
  defstruct id: nil, attributes: %{}
end
