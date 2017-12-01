defmodule TWEET.Server do 

	use GenServer

	def start_server(num, followers_num) do
		userTable = :ets.new(:user_table, [:set, :protected])
		tweetTable = :ets.new(:tweet_table, [:set, :protected])
		followTable = :ets.new(:sub_table, [:set, :protected])
		menTable = :ets.new(:men_table, [:set, :protected])
		hashtagTable = :ets.new(:hashtag_table, [:set, :protected])
		Process.register self(), String.to_atom("0")	
		run_server(userTable, tweetTable, followTable, menTable, hashtagTable)	
	end

	def run_server(userTable, tweetTable, followTable, menTable, hashtagTable) do
		receive do
			{:register, account} ->
				:ets.insert(userTable, {account, false})
				run_server(userTable, tweetTable, followTable, menTable, hashtagTable)
			{:connect, account} ->
				:ets.insert(userTable, {account, true})
				feed_tweets_to_user(account, userTable, tweetTable)
				run_server(userTable, tweetTable, followTable, menTable, hashtagTable)
			{:disconnect, account} ->
				:ets.insert(userTable, {account, false})
				run_server(userTable, tweetTable, followTable, menTable, hashtagTable)
			{:tweet, account, msg} ->
				update_hashtagTable(hashtagTable, account, msg)
				update_menTable(menTable, account, msg)
				insert_tweetlist(account, tweetTable, userTable, msg)
				feed_tweets_to_user(account, userTable, tweetTable)
				feed_follower(account, followTable, tweetTable, userTable, msg)
				run_server(userTable, tweetTable, followTable, menTable, hashtagTable)
			{:subscribe, follower, followed} ->
				update_followTable(followTable, follower, followed)
				run_server(userTable, tweetTable, followTable, menTable, hashtagTable)
			{:querytag, tag} ->
				res = :ets.lookup(hashtagTable, tag)
				print_res_hashtag(res, tag)
				run_server(userTable, tweetTable, followTable, menTable, hashtagTable)
			{:mymention, account} ->
				res = :ets.lookup(menTable, account)
				print_res_mention(res, account)
				run_server(userTable, tweetTable, followTable, menTable, hashtagTable)		
		end
	end

	def feed_follower(account, followTable, tweetTable, userTable, msg) do
		res_followers = :ets.lookup(followTable, account)
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

	def update_followTable(followTable, follower, followed) do
		case follower != followed do
			true ->
				res = :ets.lookup(followTable, followed)
				new_list = insert_follow_list(followed, res, follower)
				:ets.insert(followTable, {followed, new_list})
			false ->
				do_nothing
		end
	end

	def insert_follow_list(followed, res, follower) do
		size = Enum.count(res)
		case size do
			0 ->
				new_list = [follower]
			_ -> 
				ele = Enum.at(res, 0)
				case ele do
					{account, list} ->
						case Enum.member?(list, follower) do 
							false ->
								new_list = List.insert_at(list, 0, follower)
							true ->
								list
						end
				end
		end
	end

	def update_hashtagTable(hashtagTable, account, tweet) do
		res_hashtags = get_hashtags(tweet)
		for tag_list <- res_hashtags do
			tag = Enum.at(tag_list, 0)
			res_hashtag = :ets.lookup(hashtagTable, tag)
			size = Enum.count(res_hashtag)
			case size do
				0 ->
					:ets.insert(hashtagTable, {tag, [[account, tweet]]})
				_ ->
					ele = Enum.at(res_hashtag, 0)
					case ele do
						{hashtag, account_tweet_list} ->
							new_list = List.insert_at(account_tweet_list, 0, [account, tweet])
							:ets.insert(hashtagTable, {tag, new_list})
						_ ->
							IO.puts "Exception at update hashtag table!"
					end
			end
		end
	end

	def get_hashtags(tweet) do
		Regex.scan(~r/(?!\s)#[A-Za-z]\w*\b/, tweet)
	end

	def update_menTable(menTable, account, tweet) do
		res_mentions = get_mentions(tweet)
		for men_list <- res_mentions do
			{mention, _} = Enum.at(men_list, 0) |> String.replace_prefix("@", "") |> Integer.parse
			res_list = :ets.lookup(menTable, mention)
			size = Enum.count(res_list)
			case size do
				0 ->
					:ets.insert(menTable, {mention, [[account, tweet]]})
				_ ->
					ele = Enum.at(res_list, 0)
					case ele do
						{men, account_tweet_list} ->
							new_list = List.insert_at(account_tweet_list, 0, [account, tweet])
							:ets.insert(menTable, {mention, new_list})
						_ ->
							IO.puts "Exception at update mention table!"
					end
			end
		end
	end

	def get_mentions(tweet) do
		Regex.scan(~r/(?!\s)@[A-Za-z0-9]\w*\b/, tweet)
	end

	def print_res_hashtag(res_hashtag, tag) do
		size = Enum.count(res_hashtag)
		case size do
			0 ->
				IO.puts "no tweets with hashtag #{tag}"
			_ ->
				ele = Enum.at(res_hashtag, 0)
				case ele do
					{hashtag, account_tweet_list} ->
						IO.puts "tweets in hashtag #{tag}"
						for [account, tweet] <- account_tweet_list do
							IO.puts "account(#{account}): #{tweet}"
						end
					_ ->
						IO.puts "Exception at print_res_hashtag"
				end
		end
	end

	def print_res_mention(res_mention, mention) do
		size = Enum.count(res_mention)
		case size do
			0 ->
				IO.puts "You have no mentions."
			_ ->
				ele = Enum.at(res_mention, 0)
				case ele do
					{mention, account_tweet_list} ->
						IO.puts "my mention(account#{mention}):"
						for [account, tweet] <- account_tweet_list do
							IO.puts "account(#{account}): #{tweet}"
						end
					_ ->
						IO.puts "Exception at print_res_mention"
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