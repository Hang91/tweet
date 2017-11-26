defmodule TweetTest do
  use ExUnit.Case
  doctest Tweet

  test "greets the world" do
    assert Tweet.hello() == :world
  end
end
