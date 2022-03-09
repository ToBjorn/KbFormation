defmodule CRUDTest do
  use ExUnit.Case, async: true

  setup do
    _ = start_supervised!({Server.Database, [name: :test]})
    %{name: :test}
  end

  test "get not found", %{name: name} do
    assert GenServer.call(name, {:get, :test}) == :notFound
  end

  test "post success", %{name: name}do
    assert GenServer.call(name, {:post, {:key, 3}}) == :created
  end

  test "post conflict", %{name: name} do
    GenServer.call(name, {:post, {:key, 3}})
    assert GenServer.call(name, {:post, {:key, 3}}) == :conflict
  end

  test "get success", %{name: name} do
    GenServer.call(name, {:post, {:key, 3}})
    assert GenServer.call(name, {:get, :key}) == [key: 3]
  end

  test "delete success", %{name: name} do
    GenServer.call(name, {:post, {:key, 3}})
    GenServer.cast(name, {:delete, :key})
    assert GenServer.call(name, {:get, :key}) == :notFound
  end
end
