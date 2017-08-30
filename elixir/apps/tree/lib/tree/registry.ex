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
    import Supervisor.Spec
    %Node{id: id} = node
    spec = supervisor(Tree.Node.Supervisor,[node], restart: :temporary, id: id)
    {:ok, pid} = Supervisor.start_child(parent, spec)
    GenServer.call(@registry, {:register, node, pid})
  end

  def lookup(what) do
    GenServer.call(@registry, {:lookup, what})
  end

  def delete_all do
    GenServer.cast(@registry, :delete_all)
  end

  def handle_call(:nodes, _from, nodes) do
    {:reply, nodes, nodes}
  end

  def handle_call({:register, node, pid}, _from, nodes) do
    {:reply, node, [{node.id, pid} | nodes]}
  end

  def handle_call({:lookup, what}, _from, nodes) do
    node = Enum.find(nodes, what)
    {:reply, node, nodes}
  end

  # TODO: Stop nodes!
  def handle_cast(:delete_all, nodes) do
    {:noreply, []}
  end
end
