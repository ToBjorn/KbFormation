defmodule Step0Test do
  use ExUnit.Case
  doctest Step0

  test "greets the world" do
    assert Step0.hello() == :world
  end
end
