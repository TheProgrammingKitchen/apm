defmodule ApmIssues.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {ApmIssues.Repo,:issues}
    ]

    opts = [strategy: :one_for_one, name: ApmIssues.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
