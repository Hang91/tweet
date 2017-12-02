## Group member:
Hang Jin, Ying Zhu

## Implementation
Every client has two processes. One is for periods of live connection and disconnection, the other is working for tweet functions. Server has one process for server side tweet functions. 

At start, clients will register their account on server and connect server.
Next, every client will subscribe other clients following Zipf's distribution. Except Zipf's distribution, every client will also follow 1 client randomly. 
Next, clients will send one tweet "#hashtag This is the start of ACCOUNT. @mention"(ACCOUNT is the account of client.) with randomly added #hashtag and @mention. 
Next, they will retweet one of tweets in their timeline. 
Finally, they will disconnect from server. Then the client come to randomly connection and disconnection period.

There is a process for user interface. You can use it following the guidance in console. Notice, retweet number is displayed in your tweets timeline, which isn't showed after querying #hashtag or @mymention. 

## Using method
./tweet clientNumber rank1ClientFollowerNumber

For example, if you input: "./tweet 10000 5000", which means the system has 10000 clients and the rank1 client has 5000 followers, and the other client's followers will be arranged accorindg to Zipf's distribution.

Then you can use the user interface following the guidance in console. 

## Zipf's distribution
Number of followers of rank i client = number of followers of rank 1 client / i; 

## Performance
I evaluate the performance in the report.