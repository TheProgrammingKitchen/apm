defmodule ApmPx.Web.SessionHelper do
  defmacro __using__(_opts) do
    quote do
      use ApmPx.Web.ConnCase, async: false
      use ExUnit.Case
      use Hound.Helpers

      hound_session()

      setup do
        ApmIssues.Registry.drop!
        ApmPx.Fixtures.read
        |> ApmIssues.seed
        :ok
      end

      defp select_role(role) do
        find_element(:css, "#role-selector option[value='#{role}']") |> click()
      end

      defp login_as(user, role) do
        navigate_to("http://localhost:4000")
        element = find_element(:name, "user")
        fill_field(element, user)
        select_role(role)
        submit_element(element)
      end

    end
  end
end

