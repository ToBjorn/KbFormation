defmodule Server.Worker do
  use GenServer

  def start_link([order_id]) do
    GenServer.start_link(__MODULE__, order_id, name: String.to_atom(order_id), timeout: 5000)
  end

  def call(order_id, order) do
    GenServer.call(String.to_atom(order_id), order)
  end

  def init(order_id) do
    {:ok, order_id}
  end

  def handle_info(:timeout, state) do
    {:stop, "", state}
  end

  def handle_call(order, _from, state) do
    case ExFSM.Machine.event(order, {:process_payment, [true]}) do
      {:next_state, updated_order} -> {:reply, {:updated, updated_order}, state, 300_000}
      {:error, _} -> {:reply, {:error, order}, state, 300_000}
    end
  end
end
