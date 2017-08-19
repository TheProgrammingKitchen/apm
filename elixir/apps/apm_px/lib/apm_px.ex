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
      supervisor(ApmRepository.Dictionary,[]),
      supervisor(ApmIssues.Repo,[:issues]),
      supervisor(ApmPx.Web.Endpoint, [])
    ]

    opts = [strategy: :one_for_one, name: ApmPx.Supervisor]
    
    Supervisor.start_link(children, opts)
  end

end
