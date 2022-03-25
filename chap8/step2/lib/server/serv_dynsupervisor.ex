defmodule Server.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(order_id) do
    case DynamicSupervisor.start_child(__MODULE__, {Server.Worker, [order_id]}) do
      {:ok, child} -> child
      {:error, {:already_started, child}} -> "already started"
      {:ok, child, info} -> {child, info}
      info -> info
    end
  end
end
