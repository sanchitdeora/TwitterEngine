# TwitterEngine
Distributed Operating System - Project 4.1  

## Problem Definition  

To implement a Twitter-like engine and (in Project 4.2) pair up with Web Sockets to provide full functionality. The client part (send/receive tweets) and the engine (distribute tweets) were simulated in separate OS processes.

### Team Members:  
Sanchit Deora(8909 - 4939)  
Rohit Devulapalli (4787- 4434)
 
### Functionalities Implemented  
Register Account    
Delete Account    
Post Tweets  
Subscribe other users  
Get Tweets for specific hashtags  
Get Tweets where the user is mentioned
Retweet a tweet
If the user is connected, deliver the above types of tweets live (without querying)

### Test Cases Created for following scenarios
  
#### Registering Test Account:
	User created, User already exists, Username is empty, Password field is empty.

#### Send Tweets:
	Successfully posted tweet, Invalid username
	
#### Subscribe other users:
	Registering other users initially, Invalid username of host, Invalid password of host, Subscribing username cannot be empty, Already Subscribed to user, User you are trying to subscribe does not exist
	
#### Fetch Tweets By HashTag:
	Registering users, Posting tweets, Extracting username(s) and tweet(s) if the input hashtag(s) are valid, Input Hashtag(s) being empty, Invalid input hashtag(s)
	
#### Get my mentions 
     Tweet exists for the mentioned user, Tweet does not exist for the mentioned user
	 
#### Delete User 
     User created, existing user deleted, trying to delete a user who does not exist
	 
#### Retweet Subscriber's tweets
	Multiple Users created, send tweets, retweets received, and get my retweets

### Instructions to run the code:  
`mix run proj4.exs num_user num_msg  

For Running the Test Cases,
`mix test 

This command is for Windows OS.   

### Output

`C:\...\Project 4.1\Twitter Engine\twitter_engine>mix run proj4.exs 750 100

`Time taken to complete the simulation is 35562 milliseconds


`C:\...\Project 4.1\Twitter Engine\twitter_engine>mix test

`Finished in 0.2 seconds
`7 tests, 0 failures

`Randomized with seed 144000
