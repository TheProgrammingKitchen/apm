defmodule Tree.Registry do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(registry) do
    {:ok, registry}
  end

  def state() do
    GenServer.call(__MODULE__, :state)
  end

  def new_tree(name) do
    {:ok, GenServer.call(__MODULE__, {:new_tree, name})}
  end

  def lookup(name) do
    GenServer.call(__MODULE__, {:lookup, name})
  end

  def drop!() do
    GenServer.cast(__MODULE__, :drop)
  end

  #
  # GenServer Callbacks
  #

  def handle_call(:state, _from, registry) do
    {:reply, registry, registry}
  end

  def handle_call({:new_tree, name}, _from, registry) do
    import Supervisor.Spec
    specs = worker(Tree.Bucket, [], id: name, restart: :temporary)
    {:ok, pid} = Supervisor.start_child(Tree.Supervisor, specs)
    Process.monitor(pid)
    {:reply, pid, [ { name, pid } | registry ]}
  end

  def handle_call({:lookup, search}, _from, registry) do
    found =
    case Enum.find(registry, fn({name, _pid}) ->
      name == search
    end) do
      nil -> :not_found
      {_name, pid} -> pid
    end
    {:reply, found, registry}
  end

  def handle_cast(:drop, registry) do
    Enum.each(registry, fn({_name, pid}) -> Agent.stop(pid) end)
    {:noreply, []}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, registry) do
    {:noreply, Enum.reject(registry, fn({_name,tree}) -> pid == tree end)}
  end
end
