## Group member:
Hang Jin, Ying Zhu

## Implementation
Every client has two processes. One is for periods of live connection and disconnection, the other is working for tweet functions. Server has one process for server side tweet functions. 

At start, clients will register their account on server and connect server.
Next, every client will subscribe other clients following Zipf's distribution. Except Zipf's distribution, every client will also follow 3 clients randomly. 
Next, clients will send one tweet "#hashtag This is the start of ACCOUNT. @mention"(ACCOUNT is the account of client.) with randomly added #hashtag and @mention. 
Next, they will retweet one of tweets in their timeline. 
Finally, they will disconnect from server. Then the client come to randomly connection and disconnection period.

There is a process for user interface. You can use it following the guidance in console. Notice, retweet number is displayed in your tweets timeline, which isn't showed after querying #hashtag or @mymention. 

## Using method
./tweet clientNumber rank1ClientFollowerNumber

For example, if you input: "./tweet 10000 5000", which means the system has 10000 clients and the rank1 client has 5000 followers, and the other client's followers will be arranged accorindg to Zipf's distribution.

Please use the interface until the CPU using rate reducing to 1% or less.


## Zipf's distribution
I set the followers of rank i client are rank i + 1 to rank i + followers number. For example, if there are 2000 clients, and the number of followers of rank 1 client is 1000, the rank of clients who follow rank 1 clientr will be 2 to 1001; the rank of clients who follow rank 2 client will be 3 to 503...

## Performance
The CPU using rate will come to 1% or less after the server finished all requests from clients.
I tried 10000 clients and 5000 followers for rank 1 client, and waited about 5 seconds for the CPU using rate reducing to 1% or less. Then I tried 100000 users and 50000 followers for rank 2 user, it took about 4 minutes. 

This is a reasonable time. Since there is only one process for server, the reduing time should be linear to the number of manipulations. According to Zipf's distribution, the number of manipulations should be O(n^2) + O(m) where n is the number of followers of rank 1 client and m is the number of clients. Therefore, the time cost for "./tweet 100000 50000" will be 100 times of the time cost for "./tweet 10000 5000", since O(50000 * 50000) >> O(100000). 