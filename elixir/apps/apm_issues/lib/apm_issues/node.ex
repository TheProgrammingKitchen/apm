defmodule ApmIssues.Node do
  @moduledoc"""
  Structure to register in `ApmIssues.Registry`.

      defstruct id: nil,        # UUID
                attributes: nil,# PID of data Agent
                parent: nil,    # PID of parent Node.Supervisor
                supervisor: nil # This node's supervisor pid
  """
  defstruct id: nil,        # UUID
            attributes: nil,# PID of data Agent
            parent: nil,    # PID of parent Node.Supervisor
            supervisor: nil # This node's supervisor pid
end
