defmodule ApmPx do
  require Logger
  @moduledoc """
  The _Phoenix Frontend_ application for the _Agile Project Manager_

  as created by mix phoenix.new.

  It starts supervisors for the `ApmPx.Endpoint` and the 
  `ApmIssues.Repository`. 
  """
  use Application

  @doc false
  def start(_type, _args) do
    Application.ensure_all_started(:apm_issues)
    import Supervisor.Spec

    children = [
      supervisor(ApmPx.Web.Endpoint, []),
    ]

    opts = [strategy: :one_for_one, name: ApmPx.Supervisor]
    
    supervisors = Supervisor.start_link(children, opts)

    unless System.get_env("MIX_ENV") == "production" do
      Logger.info "STARTING WITH SEEDS FROM FIXTURE FILES ./data/fixutures/issues.json"
      Application.ensure_all_started(:apm_issues)
      ApmPx.Fixtures.read
      |> ApmIssues.seed # For development and testing only
      Logger.debug "SEEDED " <> inspect(ApmIssues.Registry.state())
    end

    supervisors
  end

end
