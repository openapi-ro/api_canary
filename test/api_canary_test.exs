defmodule ApiCanaryTest do
  use ExUnit.Case
  doctest ApiCanary

  test "greets the world" do
    assert ApiCanary.hello() == :world
  end
end
