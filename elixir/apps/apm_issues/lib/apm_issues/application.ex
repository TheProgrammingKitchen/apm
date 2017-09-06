defmodule ApmIssues.Application do
  @moduledoc"""
  The `ApmIssues.Application`, an OTP-Application, starts the
  `ApmIssues.Registry` as a worker.
  """
  use Application

  @doc false
  def start(_type, _arg) do
    children = [
      {ApmIssues.Registry, []},
    ]
    opts = [strategy: :one_for_one, name: ApmIssues.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
