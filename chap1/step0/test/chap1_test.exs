defmodule Chap1Test do
  use ExUnit.Case
  doctest Chap1

  test "greets the world" do
    assert Chap1.hello() == :world
  end
end
