defmodule ApmPx.Web.PageView do
  alias ApmPx.Web.SessionView
  use ApmPx.Web, :view


  def markdown(filename) do
    filename 
      |> File.read!
      |> Earmark.as_html!
      |> raw
  end
end
