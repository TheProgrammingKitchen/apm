defmodule Tree.Registry do
  use GenServer
  alias Tree.{Node}

  @registry __MODULE__

  def start_link(_args) do
    GenServer.start_link( @registry, [], name: @registry )
  end

  def init(nodes) do
    {:ok, nodes}
  end

  def nodes do
    GenServer.call(@registry, :nodes)
  end

  def register(node, parent) do
    GenServer.call(@registry, {:register, node, parent})
  end

  def lookup(func) when is_function(func) do
    GenServer.call(@registry, {:lookup, func})
  end

  def delete_all do
    GenServer.call(@registry, :delete_all)
  end

  #
  # GenServer Callbacks
  #

  def handle_call(:nodes, _from, nodes) do
    {:reply, nodes, nodes}
  end

  def handle_call({:register, node, parent}, _from, nodes) do
    pid = start_child_node(node,parent)
    {:reply, pid, [{node.id, pid} | nodes]}
  end

  def handle_call({:lookup, func}, _from, nodes) do
    node = Enum.find(nodes, func)
    {:reply, node, nodes}
  end

  # TODO: Stop ALL CHILDREN
  def handle_call(:delete_all, _from, nodes) do
    nodes
    |> Enum.each(fn({_id,pid}) -> 
         Process.exit(pid,:kill) 
    end)
    {:reply,:ok, []}
  end


  #
  # private helpers
  #
  defp start_child_node(node,parent) do
    import Supervisor.Spec
    spec = supervisor(Node.Supervisor,[node], restart: :temporary, id: node.id)
    {:ok, pid} = Supervisor.start_child(parent, spec)
    pid
  end

end
