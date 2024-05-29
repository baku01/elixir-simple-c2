defmodule ElixirC2Test do
  use ExUnit.Case
  doctest ElixirC2

  test "greets the world" do
    assert ElixirC2.hello() == :world
  end
end
