## Group member:
Hang Jin, Ying Zhu


## Using method
./tweet userNumber rank1UserFollowerNumber

For example, if you input: "./tweet 10000 5000", which means the system has 10000 users and the rank1 user has 5000 followers, and the other user's followers will be arranged accorindg to Zipf's distribution.



## Zipf's distribution
I set the followers of rank i are rank i + 1 to rank i + followers number. For example, if there are 2000 users, and the number of followers of rank 1 user is 1000, so the rank of users who follow rank 1 user are 2 to 1001; the rank of users who follow rank 2 user are 3 to 503...

## Max User Number
I tried 10000 users, and waited about 5 seconds for users following each other. Then I tried 100000 users, it took about 4 minutes for users following each other.