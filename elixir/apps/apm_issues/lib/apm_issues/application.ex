defmodule ApmIssues.Application do
  @moduledoc false
  use Application

  def start(_type, _arg) do
    children = [
      {ApmIssues.Registry, []},
    ]
    opts = [strategy: :one_for_one, name: ApmIssues.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
