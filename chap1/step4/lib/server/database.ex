defmodule Server.Database do
  use GenServer

  def start_link(database_name) do
    GenServer.start_link(__MODULE__, database_name[:name], database_name)
  end

  @impl true
  def init(name) do
    :ets.new(name, [:named_table])
    {:ok, name}
  end

  defp get(name, key) do
    case :ets.lookup(name, key) do
      [] -> :notFound
      x when is_list(x) -> x
    end
  end

  defp update(name, {key, value}) do
    case get(name, key) do
      [] -> :notFound
      x when is_list(x) -> :ets.insert(name, {key, value})
    end
  end

  defp delete(name, key) do
    :ets.delete(name, key)
  end

  defp post(name, value) do
    case :ets.insert_new(name, value) do
      true -> :created
      false -> :conflict
    end
  end

  @impl true
  def handle_call(instruction, _from, name) do
    case instruction do
      {:get, key} -> {:reply, get(name, key), name}
      {:update, value} when is_tuple(value) -> {:reply, update(name, value), name}
      {:post, value} when is_tuple(value) -> {:reply, post(name, value), name}
      _ -> raise "Instruction not found"
    end
  end

  @impl true
  def handle_cast(instruction, name) do
    case instruction do
      {:delete, value} ->
        delete(name, value)
        {:noreply, name}
    end
  end
end
