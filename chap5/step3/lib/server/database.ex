defmodule Server.Database do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :nil, name: __MODULE__)
  end

  def init(_param) do
    {:ok, :ets.new(__MODULE__, [:private])}
  end

  def pid do
    __MODULE__
  end

  def get do
    GenServer.call(pid(), :get)
  end

  def get(key) do
    GenServer.call(pid(), {:get, key})
  end

  def put(value) do
    GenServer.call(pid(), {:put, value})
  end

  def post(value) do
    GenServer.call(pid(), {:post, value})
  end

  def delete(key) do
    GenServer.cast(pid(), {:delete, key})
  end

  def search(criteria) do
    GenServer.call(pid(), {:search, criteria})
  end

  def handle_call({:search,  criteria}, _from, state) do
    listToReturn = Enum.reduce(criteria, [], fn {key, value}, acc ->
      case {key, value} do
        {_, value} when is_map(value) -> :ets.match_object(state, {:_, %{key => value}}) ++ acc
        {"", _} -> :ets.match_object(state, {:_, value}) ++ acc
        {_, ""} -> :ets.match_object(state, {key, :_}) ++ acc
        {key, value} -> :ets.match_object(state, {key, value}) ++ acc
      end
    end)
    {:reply, listToReturn, state}
  end

  def handle_call({:post,  values}, _from, state) do
    Enum.reduce(values, {:reply, :created, state}, fn {key, value}, toReturn ->
      case :ets.insert_new(state, {key, value}) do
        true -> toReturn
        false -> {:reply, :conflict, state}
      end
    end)
  end

  def handle_call({:put,  values}, _from, state) do
    Enum.reduce(values, {:reply, :modified, state}, fn {key, value}, toReturn ->
      case handle_call({:get, key}, self(), state) do
        {_, :notFound, _} -> {:reply, :notFound, state}
        {_, x, _} when is_list(x) ->
          :ets.insert(state, {key, value})
          toReturn
      end
    end)
  end

  def handle_call(:get, _from, state) do
    {:reply, :ets.tab2list(state), state}
  end

  def handle_call({:get, key}, _from, state) do
    case :ets.lookup(state, key) do
      [] -> {:reply, :notFound, state}
      x when is_list(x) -> {:reply, x, state}
    end
  end

  def handle_cast({:delete, key}, state) do
    :ets.delete(state, key)
    {:noreply, state}
  end

  def load_to_database(json_file) do
    json_file
    |> File.read!()
    |> Poison.decode!()
    |> Enum.each(fn elem -> GenServer.call(pid(), {:post, {elem["id"], elem}}) end)
  end
end
