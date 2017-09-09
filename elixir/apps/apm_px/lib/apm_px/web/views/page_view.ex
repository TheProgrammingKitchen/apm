defmodule ApmPx.Web.PageView do
  alias ApmPx.Web.SessionView
  use ApmPx.Web, :view


  @doc"""
  Wrap call to markdown tool to render content of `filename`.
  """
  def markdown(filename) do
    filename 
      |> File.read!
      |> Earmark.as_html!
      |> raw
  end
end
