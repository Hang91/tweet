defmodule TWEET.User do 

	use GenServer

	def start_user(account, num) do
		register(account)
		connect(account)
		followed_by(account, num)
		send_tweet1(account)
		disconnect(account)
	end

	def run_user(account) do
		run = Enum.random(1..2)
		case run do
			1 -> 
				connect(account)
			2 ->
				disconnect(account)
		end
		:timer.sleep(10000)
		run_user(account)
	end

	def register(account) do
		userName = Integer.to_string(account)
		GenServer.start(__MODULE__, [account, false, []], [name: String.to_atom(userName)])
		send String.to_atom("0"), {:register, account}
	end

	def connect(account) do
		send String.to_atom("0"), {:connect, account}
		GenServer.cast(String.to_atom(Integer.to_string(account)), {:connection, true})
	end

	def disconnect(account) do
		send String.to_atom("0"), {:disconnect, account}
		GenServer.cast(String.to_atom(Integer.to_string(account)), {:connection, false})
	end

	def send_tweet1(account) do
		msg = "This is the start of #{account}."
		send String.to_atom("0"), {:tweet, account, msg}
	end

	def send_tweet(account, msg) do
		send String.to_atom("0"), {:tweet, account, msg}
	end

	def subscribe(account, subscription) do
		send String.to_atom("0"), {:subscribe, account, subscription}
	end

	def followed_by(account, num) do
		followers_num = div(num, account)
		case followers_num >= 1 do
			true ->
				left = account + 1
				right = account + followers_num
				for n <- left..right do
					subscribe(n, account)
				end
			false ->
				do_nothing
		end
	end

	def subscribe_simulator(account, num) do
		case account do
			1 ->
				IO.puts "1 follow no one"
			_ ->
				for n <- 1..num do
					subscription = Enum.random(1..account - 1)
					subscribe(account, subscription)
				end
		end
	end

	def handle_cast(request, [account, connection, tweets]) do
		case request do
			{:login} ->
				connect(account)
				{:noreply, [account, true, tweets]}
			{:logout} ->
				disconnect(account)
				IO.puts "#{account} log out"
				{:noreply, [account, false, tweets]}
			{:tweet, msg} ->
				send_tweet(account, msg)
				{:noreply, [account, connection, tweets]}
			{:retweet, msg} ->
				send_tweet(account, msg)
				{:noreply, [account, connection, tweets]}
			{:feed, new_tweets} ->
				case connection do
					true ->
						{:noreply, [account, connection, new_tweets]}
					false ->
						{:noreply, [account, connection, tweets]}
				end
			{:connection, new_connection} ->
				{:noreply, [account, new_connection, tweets]}
			{:printtweets} ->
				print_tweets(account, tweets)
				{:noreply, [account, connection, tweets]}
			_ ->
				IO.puts "Exception at handle_cast!"
				{:noreply, [account, connection, tweets]}			 				
		end
	end

	def print_tweets(account, tweets) do
		IO.puts "tweets of #{account}: "
		size = Enum.count(tweets)
		for i <- 0..size - 1 do
			IO.puts "#{i}: #{Enum.at(tweets, i)}"
		end
	end

	def do_nothing do
	end
end