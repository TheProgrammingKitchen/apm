defmodule ApmPx.Fixtures do
  require Logger

  @moduledoc"""
  Read entries from json files. Used for (integration) tests.
  """

  @fixture_file Path.expand("../../../../../data/fixtures/issues.json", __DIR__)

  def read do
    read!(@fixture_file)
  end

 defp read!(filename) do
    File.stream!(filename)
    |> filter_remarks
    |> Poison.Parser.parse!(keys: :atoms)
    |> Enum.map( fn(spec) ->
      build_node(spec)
    end)
  end

  defp build_node(new_node) do
    case Map.has_key?(new_node, :parent_id) do
      false ->
        %ApmIssues.Node{id: new_node.id, attributes: %{subject: new_node.subject}}
      true -> 
        {%ApmIssues.Node{id: new_node.id, attributes: %{subject: new_node.subject}}, new_node.parent_id}
    end
  end

  # Ignore lines starting with \s*#
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
