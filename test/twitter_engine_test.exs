defmodule TwitterTest1 do
  use ExUnit.Case
  doctest TwitterEngine
  require Logger

  test "Registering Test Account" do
    #    {:ok, pid} = GenServer.start(DatabaseServer, %{})
    #    {:ok, server_pid} = GenServer.start(TwitterEngine, %{})
    {:ok, server_pid} = TwitterEngine.start_link([])

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    # expect a proceed to actual data server
    assert response == :proceed
    {code, message} = TwitterProcessor.registerUser(data, {"david", "warner"})

    #expect the data to be saved to database
    assert code == :ok
    assert message == "Successful"

    {code, message} = TwitterProcessor.registerUser(data, {"david", "warner"})

    #ecpect the new creation to fail as the same is duplicate
    assert code == :bad
    assert message == "Username already in use"

    {code, message} = TwitterProcessor.registerUser(data, {"david", "warner"})

    #ecpect the new creation to fail as the same is duplicate
    assert code == :bad
    assert message == "Username already in use"

    {code, message} = TwitterProcessor.registerUser(data, {"david", "warner"})

    #ecpect the new creation to fail as the same is duplicate
    assert code == :bad
    assert message == "Username already in use"

    {code, message} = TwitterProcessor.registerUser(data, {"", "warner"})

    #ecpect the new creation to fail as the same is duplicate
    assert code == :bad
    assert message == "Username cannot be empty"

    {code, message} = TwitterProcessor.registerUser(data, {"   ", "warner"})

    #ecpect the new creation to fail as the same is duplicate
    assert code == :bad
    assert message == "Username cannot be empty"

    {code, message} = TwitterProcessor.registerUser(data, {"   ", "    "})

    #ecpect the new creation to fail as the same is duplicate
    assert code == :bad
    assert message == "Username cannot be empty"

    {code, message} = TwitterProcessor.registerUser(data, {"david", "   "})

    #ecpect the new creation to fail as the same is duplicate
    assert code == :bad
    assert message == "Password cannot be empty"

    {code, message} = TwitterProcessor.registerUser(data, {"david", ""})

    #ecpect the new creation to fail as the same is duplicate
    assert code == :bad
    assert message == "Password cannot be empty"
  end

  test "Send tweets" do
    {:ok, server_pid} = TwitterEngine.start_link([])

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    # expect a proceed to actual data server
    assert response == :proceed
    {code, message} = TwitterProcessor.registerUser(data, {"david", "warner"})

    #expect the data to be saved to database
    assert code == :ok
    assert message == "Successful"

    {code, message} = TwitterProcessor.sendTweet(data, {"davd", "warner", "Tweeting for first time."})
    #expect the data to be saved to database
    assert code == :bad
    assert message == "Invalid Username"

    {code, message} = TwitterProcessor.sendTweet(data, {"david", "warner", "Tweeting for first time."})

    #expect the data to be saved to database
    assert code == :ok
    assert message == "Successful"
  end

  test "Subscribing to Users" do

    {:ok, server_pid} = GenServer.start(TwitterEngine, %{})

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.registerUser(data, {"david", "warner"})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.registerUser(data, {"virat", "kohli"})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.registerUser(data, {"chris", "gayle"})
    assert code == :ok
    assert message == "Successful"


    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.subscribeUser(data, {"davi", "warner", "virat"})
    assert code == :bad
    assert message == "Invalid Username"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.subscribeUser(data, {"david", "waner", "virat"})
    assert code == :bad
    assert message == "Invalid Username or password"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.subscribeUser(data, {"david", "warner", "chris"})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.subscribeUser(data, {"david", "warner", " "})
    assert code == :bad
    assert message == "Subscribing username cannot be empty"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.subscribeUser(data, {"david", "warner", ""})
    assert code == :bad
    assert message == "Subscribing username cannot be empty"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.subscribeUser(data, {"david", "warner", "virat"})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.subscribeUser(data, {"david", "warner", "virat"})
    assert message == "Already Subscribed to user"
    assert code == :bad

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.subscribeUser(data, {"david", "warner", "virata"})
    assert code == :bad
    assert message == "User you are trying to subscribe does not exist"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.registerUser(data, {"Rahul", "dravid"})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.deleteUser(data, {"Rahul", "dravid"})
    assert code == :ok
    assert message == "Successful"


    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.subscribeUser(data, {"david", "warner", "Rahul"})
    assert code == :bad
    assert message == "User you are trying to subscribe does not exist"


    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.sendTweet(data, {"virat", "kohli", "Virat's first tweet."})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.sendTweet(data, {"chris", "gayle", "Chris's first tweet."})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.sendTweet(data, {"virat", "kohli", "Virat's second tweet."})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.getSubscribedTweets(data, {"david", "warner"})
    assert code == :ok
    assert Enum.count(message) == 3
    [{id1, {user, _, tweet}}, {id2, {user_2, _, tweet_2}}, {id3, {user_3, _c, tweet_3}}] = message
    assert user == "virat"
    assert tweet == "Virat's second tweet."
    assert user_2 == "chris"
    assert tweet_2 == "Chris's first tweet."
    assert user_3 == "virat"
    assert tweet_3 == "Virat's first tweet."
  end

  test "Fetch Tweets By HashTag" do
    {:ok, server_pid} = GenServer.start(TwitterEngine, %{})

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.registerUser(data, {"david", "warner"})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.registerUser(data, {"chris", "gayle"})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.registerUser(data, {"yuvraj", "singh"})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.sendTweet(data, {"david", "warner", "First tweet #kangaroo."})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.getTweetsFromHashtags(data, "#kangaroo")
    assert code == :ok
    assert Enum.count(message) == 1
    [{id, {user, _, tweet}}] = message
    assert user == "david"
    assert tweet == "First tweet #kangaroo."

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.getTweetsFromHashtags(data, "")
    assert code == :bad
    assert message == "Hashtag cannot be empty"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.getTweetsFromHashtags(data, "")
    assert code == :bad
    assert message == "Hashtag cannot be empty"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.getTweetsFromHashtags(data, "#kangroo")
    assert code == :ok
    assert message == []


    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.sendTweet(data, {"chris", "gayle", "This is #universal #kangaroo."})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.getTweetsFromHashtags(data, "#kangaroo")
    assert code == :ok
    assert Enum.count(message) == 2
    [{id1, {user, _, tweet}}, {id2, {user_2, _, tweet_2}}] = message
    assert user == "chris"
    assert tweet == "This is #universal #kangaroo."
    assert user_2 == "david"
    assert tweet_2 == "First tweet #kangaroo."


    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.getTweetsFromHashtags(data, "#universal")
    assert code == :ok
    assert Enum.count(message) == 1
    [{id2, {user_2, _, tweet_2}}] = message
    assert user_2 == "chris"
    assert tweet_2 == "This is #universal #kangaroo."

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.sendTweet(data, {"yuvraj", "singh", "All time great #universal #hitter #kangaroo."})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.getTweetsFromHashtags(data, "#kangaroo")
    assert code == :ok
    assert Enum.count(message) == 3
    [{id1, {user, _, tweet}}, {id2, {user_2, _, tweet_2}}, {id3, {user_3, _c, tweet_3}}] = message
    assert user == "yuvraj"
    assert tweet == "All time great #universal #hitter #kangaroo."
    assert user_2 == "chris"
    assert tweet_2 == "This is #universal #kangaroo."
    assert user_3 == "david"
    assert tweet_3 == "First tweet #kangaroo."

  end

  test "Get my mentions" do
    {:ok, server_pid} = GenServer.start(TwitterEngine, %{})

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.registerUser(data, {"david", "warner"})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.registerUser(data, {"virat", "kohli"})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.registerUser(data, {"chris", "gayle"})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.registerUser(data, {"yuvraj", "singh"})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.sendTweet(data, {"david", "warner", "First tweet #kangaroo."})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.sendTweet(data, {"chris", "gayle", "This is #universal #kangaroo @david."})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.getMyMentions(data, {"david", "warner"})
    assert code == :ok
    assert Enum.count(message) == 1
    [{id2, {user_2, _, tweet_2}}] = message
    assert user_2 == "chris"
    assert tweet_2 == "This is #universal #kangaroo @david."

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.getMyMentions(data, {"davey", "warner"})
    assert code == :bad
    assert message == "Invalid Username"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.sendTweet(data, {"virat", "kohli", "Excellent batting @david."})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.getMyMentions(data, {"david", "warner"})
    assert code == :ok
    assert Enum.count(message) == 2
    [{id2, {user_2, _, tweet_2}}, {id3, {user_3, _, tweet_3}}] = message
    assert user_2 == "virat"
    assert tweet_2 == "Excellent batting @david."
    assert user_3 == "chris"
    assert tweet_3 == "This is #universal #kangaroo @david."

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.sendTweet(data, {"yuvraj", "singh", "Well done @david."})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.getMyMentions(data, {"david", "warner"})
    assert code == :ok
    assert Enum.count(message) == 3
    [{id2, {user_2, _, tweet_2}}, {id3, {user_3, _, tweet_3}}, {id4, {user_4, _, tweet_4}}] = message
    assert user_2 == "yuvraj"
    assert tweet_2 == "Well done @david."
    assert user_3 == "virat"
    assert tweet_3 == "Excellent batting @david."
    assert user_4 == "chris"
    assert tweet_4 == "This is #universal #kangaroo @david."

  end

  test "Retweet Subscriber's tweets" do
    {:ok, server_pid} = GenServer.start(TwitterEngine, %{})

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.registerUser(data, {"david", "warner"})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.registerUser(data, {"virat", "kohli"})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.registerUser(data, {"chris", "gayle"})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.sendTweet(data, {"david", "warner", "First tweet #kangaroo."})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.sendTweet(data, {"chris", "gayle", "This is #universal #kangaroo @david."})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.getMyMentions(data, {"david", "warner"})
    assert code == :ok
    assert Enum.count(message) == 1
    [{id2, {user_2, _, tweet_2}}] = message
    assert user_2 == "chris"
    assert tweet_2 == "This is #universal #kangaroo @david."

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.sendTweet(data, {"virat", "kohli", "Excellent batting @david."})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.getTweetsFromHashtags(data, "#kangaroo")
    assert code == :ok
    assert Enum.count(message) == 2
    [{id1, {user, _, tweet}}, {id2, {user_2, _, tweet_2}}] = message
    assert user == "chris"
    assert tweet == "This is #universal #kangaroo @david."
    assert user_2 == "david"
    assert tweet_2 == "First tweet #kangaroo."


    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.retweet(data, {"david", "warner", id1})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.getMyMentions(data, {"david", "warner"})
    assert code == :ok
    assert Enum.count(message) == 2
    [{id2, {user_2, _, tweet_2}}, {id3, {user_3, _, tweet_3}}] = message
    assert user_2 == "virat"
    assert tweet_2 == "Excellent batting @david."
    assert user_3 == "chris"
    assert tweet_3 == "This is #universal #kangaroo @david."


    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.retweet(data, {"david", "warner", id2})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response==:proceed
    {code, message} = TwitterProcessor.getMyRetweets(data, {"david", "warner"})
    assert code == :ok
    assert Enum.count(message) == 2
    [{id1, {user_1, _, tweet_1}}, {id2, {user_2, _, tweet_2}}] = message
    assert user_1 == "virat"
    assert tweet_1 == "Excellent batting @david."
    assert user_2 == "chris"
    assert tweet_2 == "This is #universal #kangaroo @david."

  end

  test "Delete User" do

    {:ok, server_pid} = GenServer.start(TwitterEngine, %{})

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.registerUser(data, {"david", "warner"})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.deleteUser(data, {"david", "warner"})
    assert code == :ok
    assert message == "Successful"

    {response, data} = TwitterEngine.chooseProcessor(server_pid)
    assert response == :proceed
    {code, message} = TwitterProcessor.deleteUser(data, {"david", "warner"})
    assert code == :ok
    assert message == "Successful"

  end

end