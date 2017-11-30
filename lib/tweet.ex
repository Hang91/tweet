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
    {num,args} = List.pop_at(args,0)
    {followers_num,args} = List.pop_at(args,0)
    IO.puts "num is #{num}, followers number is #{followers_num}"
    Simulator.start_simulator(String.to_integer(num), String.to_integer(followers_num))
  end
end
