defmodule ApmPx do
  @moduledoc """
  The _Phoenix Frontend_ application for the _Agile Project Manager_

  as created by mix phoenix.new.

  It starts supervisors for the `ApmPx.Endpoint` and the 
  `ApmIssues.Repository`. 
  """
  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      #worker(ApmRepository.Dictionary, [:issues]),
      worker(ApmIssues.Repo,[:issues]),
      supervisor(ApmPx.Endpoint, [])
    ]

    opts = [strategy: :one_for_one, name: ApmPx.Supervisor]

    #Application.ensure_all_started(:apm_repository,:permanent)
    
    Supervisor.start_link(children, opts)
  end

  @doc false
  def config_change(changed, _new, removed) do
    ApmPx.Endpoint.config_change(changed, removed)
    :ok
  end
end
