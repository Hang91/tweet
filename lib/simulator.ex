defmodule Simulator do
	use GenServer
	def start_simulator(num, followers_num) do
		spawn fn -> TWEET.Server.start_server(num, followers_num) end
		for i <- 1..num do
			spawn fn -> TWEET.User.start_user(i, followers_num) end
		end
		run_interface(num)
	end

	def run_interface(num) do
		{account, _} = IO.gets("log in an account(input range 1..#{num}): ") |> Integer.parse
		log_in(account)
		IO.gets("Input anything to log out: ")
		log_out(account)	
		run_interface(num)
	end

	def log_in(account) do
		GenServer.cast(String.to_atom(Integer.to_string(account)), {:login})
		:timer.sleep(1000)
		GenServer.cast(String.to_atom(Integer.to_string(account)), {:printtweets})
	end

	def log_out(account) do
		GenServer.cast(String.to_atom(Integer.to_string(account)), {:logout})
	end

end