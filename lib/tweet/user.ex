defmodule TWEET.User do 

	use GenServer

	def start_user(account, num, followers_num) do
		register(account)
		connect(account)
		followed_by(account, num, followers_num)
		send_tweet1(account, num)
		random_retweet(account)
		disconnect(account)
		run_user(account)
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

	def send_tweet1(account, limit) do
		hashtag_list = ["#cry", "#indeed", "#flag", "#glassdoor", "#job", "#elixir", "#java", "#erlang", "#javaScript", "#CSS/HTML", "#C/C++"]
		men_flag = Enum.random(1..5)
		tag_flag = Enum.random(1..3)
		case men_flag do
			1 ->
				mention = Enum.random(1..limit)
				case tag_flag do
					1 ->
						tag = Enum.random(hashtag_list)
						msg = "#{tag} This is the start of #{account}. @#{mention}"
						send String.to_atom("0"), {:tweet, account, msg}
					_ ->
						msg = "This is the start of #{account}. @#{mention}"
						send String.to_atom("0"), {:tweet, account, msg}
				end
			_ ->
				case tag_flag do
					1 ->
						tag = Enum.random(hashtag_list)
						msg = "#{tag} This is the start of #{account}."
						send String.to_atom("0"), {:tweet, account, msg}
					_ ->
						msg = "This is the start of #{account}."
						send String.to_atom("0"), {:tweet, account, msg}
				end
		end
	end

	def send_tweet(account, msg) do
		send String.to_atom("0"), {:tweet, account, msg}
	end

	def random_retweet(account) do
		:timer.sleep(1000)
		GenServer.cast(String.to_atom(Integer.to_string(account)), {:randomretweet})
	end

	def subscribe(account, subscription) do
		send String.to_atom("0"), {:subscribe, account, subscription}
	end

	def followed_by(account, num, follow_num) do
		followers_num = div(follow_num, account)
		follow_list = Enum.take_random(1..num, followers_num)
		if followers_num >= 1 do
			for follower <- follow_list do
				if follower != account do
					subscribe(follower, account)
				end
			end
		end
	end

	def random_subscribe(account, num, limit) do
		for n <- 1..num do
			subscription = Enum.random(1..limit)
			subscribe(account, subscription)
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
			{:retweet, num} ->
				size = Enum.count(tweets)
				if num < size do
					msg = Enum.at(tweets, num)
					send_tweet(account, "#{account} retweet: #{msg}")
				end
				{:noreply, [account, connection, tweets]}
			{:randomretweet} ->
				size = Enum.count(tweets)
				case size do
					0 ->
						random_retweet(account)
					_ ->
						msg = Enum.random(tweets)
						send_tweet(account, "#{account} retweet: #{msg}")
				end
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
			IO.puts "num(#{i}): #{Enum.at(tweets, i)}"
		end
	end

	def do_nothing do
	end
end