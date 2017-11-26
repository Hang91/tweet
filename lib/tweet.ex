defmodule Tweet do
  @moduledoc """
  Documentation for Tweet.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Tweet.hello
      :world

  """
  def hello do
    :world
  end

  def main(args) do
    {numNodes,args} = List.pop_at(args,0)
    IO.puts "num of users: #{numNodes}"
  end
end
