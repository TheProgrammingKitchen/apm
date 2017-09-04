defmodule ApmIssues.Node do
  @moduledoc"""
  Structure to register a `ApmIssues.Node` in `ApmIssues.Registry`.
  A _Node_ is being represented as a tuple of `{id, supervisor_pid, data_agent_pid}`.

      defstruct id: nil,           # UUID
                attributes: nil,   # PID of data Agent
                parent: nil,       # PID of parent Node.Supervisor
                supervisor: nil    # This node's supervisor pid

  """
  defstruct id: nil,        
            attributes: nil,
            parent: nil,   
            supervisor: nil

end
