defmodule TWEET.Server do 

	use GenServer

	def start_server(num, followers_num) do
		userTable = :ets.new(:user_table, [:set, :protected])
		tweetTable = :ets.new(:tweet_table, [:set, :protected])
		subTable = :ets.new(:sub_table, [:set, :protected])
		menTable = :ets.new(:men_table, [:set, :protected])
		Process.register self(), String.to_atom("0")	
		run_server(userTable, tweetTable, subTable, menTable)	
	end

	def run_server(userTable, tweetTable, subTable, menTable) do
		receive do
			{:register, account} ->
				:ets.insert(userTable, {account, false})
				run_server(userTable, tweetTable, subTable, menTable)
			{:connect, account} ->
				:ets.insert(userTable, {account, true})
				feed_tweets_to_user(account, userTable, tweetTable)
				run_server(userTable, tweetTable, subTable, menTable)
			{:disconnect, account} ->
				:ets.insert(userTable, {account, false})
				run_server(userTable, tweetTable, subTable, menTable)
			{:tweet, account, msg} ->
				insert_tweetlist(account, tweetTable, userTable, msg)
				feed_tweets_to_user(account, userTable, tweetTable)
				feed_follower(account, subTable, tweetTable, userTable, msg)
				run_server(userTable, tweetTable, subTable, menTable)
			{:subscribe, follower, subscription} ->
				res = :ets.lookup(subTable, subscription)
				new_list = insert_sublist(subscription, res, follower)
				:ets.insert(subTable, {subscription, new_list})
				run_server(userTable, tweetTable, subTable, menTable)
		end
	end

	def feed_follower(account, subTable, tweetTable, userTable, msg) do
		res_followers = :ets.lookup(subTable, account)
		size = Enum.count(res_followers)
		case size do
			0 ->
				do_nothing
			_ ->
				tuple = Enum.at(res_followers, 0)
				case tuple do
					{account, follower_list} ->
						for follower <- follower_list do
							insert_tweetlist(follower, tweetTable, userTable, msg)
						end
					_ ->
						IO.puts "Exception at feed follower!"
				end
		end	
	end

	def feed_tweets_to_user(user, userTable, tweetTable) do
		tweets = find_tweets(user, tweetTable)
		res_connection = :ets.lookup(userTable, user)
		size = Enum.count(res_connection)
		case size do
			0 -> 
				do_nothing
			_ ->
				ele = Enum.at(res_connection, 0)
				case ele do
					{account, connection} ->
						case connection do
							true -> 
								GenServer.cast(String.to_atom(Integer.to_string(user)), {:feed, tweets})
							false ->
								do_nothing
						end
					_ ->
						IO.puts "Exception at feed tweets to user!"
				end
		end
	end

	def find_tweets(account, tweetTable) do
		res_tweets = :ets.lookup(tweetTable, account)
		size = Enum.count(res_tweets)
		case size do
			0 ->
				[]
			_ ->
				ele = Enum.at(res_tweets, 0)
				case ele do
					{account, tweets} ->
						tweets
					_ ->
						IO.puts "Exception at find tweets!"
						[]
				end
		end
	end

	def insert_tweetlist(account, tweetTable, userTable, msg) do
		res_tweets = :ets.lookup(tweetTable, account)
		size = Enum.count(res_tweets)
		case size do
			0 -> 
				:ets.insert(tweetTable, {account, [msg]})
				feed_tweets_to_user(account, userTable, tweetTable)	
			_ ->			
				ele = Enum.at(res_tweets, 0)
				case ele do
					{account, list} ->
						new_list = List.insert_at(list, 0, msg)
						:ets.insert(tweetTable, {account, new_list})
						feed_tweets_to_user(account, userTable, tweetTable)
					_ ->
						IO.puts "Exception at insert tweet list!"
				end	
		end
	end

	def insert_sublist(subscription, res, follower) do
		size = Enum.count(res)
		case size do
			0 ->
				newList = [follower]
			_ -> 
				ele = Enum.at(res, 0)
				case ele do
					{account, list} ->
						case Enum.member?(list, follower) do 
							false ->
								newList = List.insert_at(list, 0, follower)
							true ->
								list
						end
				end
		end
	end

	def print_res(res) do
		size = Enum.count(res)
		case size do
			0 ->
				IO.puts "no tweets"
			_ ->

				ele = Enum.at(res, 0)
				case ele do
					{account, tweet_list} ->
						IO.puts "tweets of #{account}"
						for msg <- tweet_list do
							IO.puts msg
						end
				end	
		end
	end

	def do_nothing do
	end
end