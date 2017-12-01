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
		IO.puts("log in an account(input range 1..#{num}): ")
		{account, _} = IO.gets("") |> Integer.parse
		log_in(account, num)
	end

	def log_in(account, num) do
		GenServer.cast(String.to_atom(Integer.to_string(account)), {:login})
		:timer.sleep(50)
		GenServer.cast(String.to_atom(Integer.to_string(account)), {:printtweets})
		:timer.sleep(100)
		run_login(account, num)
	end

	def run_login(account, num) do
		IO.puts("input keyword: hashtag, mymention, tweet, retweet, refresh or logout: ")
		input = IO.gets("") |> String.replace_suffix("\n", "")
		case input do
			"hashtag" -> query_hashtag(account, num)
			"logout" -> log_out(account, num)
			"tweet" -> send_tweet(account, num)
			"retweet" -> retweet(account, num)
			"refresh" -> refresh(account, num)
			"mymention" -> my_mention(account, num)
			_ -> 
				IO.puts "Illegal input!"
				run_login(account, num)
		end
	end

	def query_hashtag(account, num) do
		IO.puts "input hashtag(#job): "
		input = IO.gets("") |> String.replace_suffix("\n", "")
		res_hashtags = get_hashtags(input)
		for tag_list <- res_hashtags do
			tag = Enum.at(tag_list, 0)
			send String.to_atom("0"), {:querytag, tag}
		end
		:timer.sleep(100)
		run_login(account, num)
	end

	def my_mention(account, num) do
		send String.to_atom("0"), {:mymention, account}
		:timer.sleep(100)
		run_login(account, num)
	end

	def refresh(account, num) do
		log_in(account, num)
	end

	def retweet(account, num) do
		IO.puts "Input the num of tweet(the number before tweets after you did tweet, login, refresh or retweet): "
		{number, _} = IO.gets("") |> Integer.parse
		GenServer.cast(String.to_atom(Integer.to_string(account)), {:retweet, number})
		refresh(account, num)	
	end

	def send_tweet(account, num) do
		IO.puts "input tweet: "
		msg = IO.gets("") |> String.replace_suffix("\n", "")
		GenServer.cast(String.to_atom(Integer.to_string(account)), {:tweet, msg})
		:timer.sleep(100)
		refresh(account, num)
	end

	def get_hashtags(tweet) do
		Regex.scan(~r/(?!\s)#[A-Za-z]\w*\b/, tweet)
	end

	def log_out(account, num) do
		GenServer.cast(String.to_atom(Integer.to_string(account)), {:logout})
		:timer.sleep(100)
		run_interface(num)
	end

end