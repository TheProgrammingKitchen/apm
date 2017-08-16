defmodule ApmIssues.Adapter.File do
  @moduledoc"""
    The module is responsible to load issues from a JSON-file
    and use `ApmIssues.Adapter` to push them to the repository.

    ## Dependency:
    `devinius/poison` to parse the json-string, loaded from the file.
  """

  @doc"""
    Stream from given file, filter remarks and push the entire JSON-objects
    to the repository.
    Please [read about `keys: :atoms`](https://github.com/devinus/poison#parsere).
    The decision to use :atoms here was made because the number of keys used 
    in `ApmIssues.Issue` will be limited.
  """
  def read!(filename) do
    File.stream!(filename)
    |> filter_remarks
    |> Poison.Parser.parse!(keys: :atoms)
    |> ApmIssues.Adapter.push
  end

  defp filter_remarks lines do
    Stream.map(lines, fn(line) ->
      case Regex.match?(~r/\A\s*#.*\Z/, line) do
        true -> ""
        _ -> line
      end
    end)
    |> Enum.join("\n")
  end

end
