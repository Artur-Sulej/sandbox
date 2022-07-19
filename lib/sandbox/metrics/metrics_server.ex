defmodule Sandbox.MetricsServer do
  use GenServer

  alias Phoenix.PubSub

  @name :metrics
  @topic "metrics"

  def topic do
    @topic
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def current() do
    GenServer.call(@name, :current_state)
  end

  def increment(key) do
    GenServer.call(@name, {:increment, key})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:current_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:increment, key}, _from, state) do
    new_state = Map.update(state, key, 1, fn value -> value + 1 end)
    PubSub.broadcast(Sandbox.PubSub, topic(), {:update_metrics, new_state})
    {:reply, new_state, new_state}
  end
end
