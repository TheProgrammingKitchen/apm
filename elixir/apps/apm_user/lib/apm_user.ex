defmodule ApmUser do
  @moduledoc """
  `ApmUser` is a very simple module by now. There is no 
  repository based implementation yet and any combination
  of user/password is accepted at login!

  Although the modules defines possible `Role`s for the application,
  thus we can check against their functional permissions.
  """

  alias ApmUser.Role

  @doc """
  Default role is :guest

  FIXME: Roles should be defined in config

  ## Examples

      iex> Enum.find_value( ApmUser.roles, fn(role) -> role.key == :guest end)
      true
        

  """
  def roles do
    [
      %Role{ key: :guest, name: "Guest" },
      %Role{ key: :admin, name: "Admin" },
      %Role{ key: :customer, name: "Customer" },
      %Role{ key: :product_manager, name: "Product Manager" },
      %Role{ key: :product_owner, name: "Product Owner" },
      %Role{ key: :developer, name: "Developer" },
      %Role{ key: :qa_engineer, name: "QA Engineer" },
      %Role{ key: :operator, name: "Operator" }
    ]
  end
end
