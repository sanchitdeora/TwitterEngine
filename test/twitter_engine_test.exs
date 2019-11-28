defmodule TwitterTest do
  use ExUnit.Case
  doctest TwitterLoadBalance
  require Logger

  test "Test Account Creation" do
#    {:ok, pid} = GenServer.start(DatabaseServer, %{})
#    {:ok, server_pid} = GenServer.start(TwitterLoadBalance, %{})
    {:ok, server_pid} = TwitterLoadBalance.start_link([])

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    # expect a redirect to actual data server
    assert response == :redirect
    {code, message} = TwitterProcessor.registerUser(data, {"ranbir", "roshan"})

    #expect the data to be saved to database
    assert code == :ok
    assert message == "Success"

    {code, message} = TwitterProcessor.registerUser(data, {"ranbir", "roshan"})

    #ecpect the new creation to fail as the same is duplicate
    assert code == :bad
    assert message == "Username already in use"

    {code, message} = TwitterProcessor.registerUser(data, {"ranbir", "roshan"})

    #ecpect the new creation to fail as the same is duplicate
    assert code == :bad
    assert message == "Username already in use"

    {code, message} = TwitterProcessor.registerUser(data, {"ranbir", "roshan"})

    #ecpect the new creation to fail as the same is duplicate
    assert code == :bad
    assert message == "Username already in use"

    {code, message} = TwitterProcessor.registerUser(data, {"", "roshan"})

    #ecpect the new creation to fail as the same is duplicate
    assert code == :bad
    assert message == "Username cannot be empty"

    {code, message} = TwitterProcessor.registerUser(data, {"   ", "roshan"})

    #ecpect the new creation to fail as the same is duplicate
    assert code == :bad
    assert message == "Username cannot be empty"

    {code, message} = TwitterProcessor.registerUser(data, {"   ", "    "})

    #ecpect the new creation to fail as the same is duplicate
    assert code == :bad
    assert message == "Username cannot be empty"

    {code, message} = TwitterProcessor.registerUser(data, {"ranbir", "   "})

    #ecpect the new creation to fail as the same is duplicate
    assert code == :bad
    assert message == "Password cannot be empty"

    {code, message} = TwitterProcessor.registerUser(data, {"ranbir", ""})

    #ecpect the new creation to fail as the same is duplicate
    assert code == :bad
    assert message == "Password cannot be empty"
  end

  test "Post tweets" do
    {:ok, server_pid} = TwitterLoadBalance.start_link([])

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    # expect a redirect to actual data server
    assert response == :redirect
    {code, message} = TwitterProcessor.registerUser(data, {"ranbir", "roshan"})

    #expect the data to be saved to database
    assert code == :ok
    assert message == "Success"

    {code, message} = TwitterProcessor.postTweet(data, {"ranir", "roshan", "My first tweet."})
    Logger.info("#{message}")
    #expect the data to be saved to database
    assert code == :bad
    assert message == "Invalid Username"

    {code, message} = TwitterProcessor.postTweet(data, {"ranbir", "roshan", "My first tweet."})

    #expect the data to be saved to database
    assert code == :ok
    assert message == "Success"
  end
  test "Subscribe User" do

    {:ok, server_pid} = GenServer.start(TwitterLoadBalance, %{})

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.registerUser(data, {"ranbir", "roshan"})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.registerUser(data, {"sid", "jain"})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.registerUser(data, {"jay", "patel"})
    assert code == :ok
    assert message == "Success"


    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.subscribeUser(data, {"rabir", "roshan", "sid"})
    assert code == :bad
    assert message == "Invalid Username"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.subscribeUser(data, {"ranbir", "rosan", "sid"})
    assert code == :bad
    assert message == "Invalid Username or password"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.subscribeUser(data, {"ranbir", "roshan", "jay"})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.subscribeUser(data, {"ranbir", "roshan", " "})
    assert code == :bad
    assert message == "Subscribing username cannot be empty"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.subscribeUser(data, {"ranbir", "roshan", ""})
    assert code == :bad
    assert message == "Subscribing username cannot be empty"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.subscribeUser(data, {"ranbir", "roshan", "sid"})
    assert code == :ok
    assert message == "Success"
    Logger.info("#{message} 1")

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.subscribeUser(data, {"ranbir", "roshan", "sid"})
    assert message == "Already Subscribed to user"
    assert code == :bad
    Logger.info("#{message} 1")

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.subscribeUser(data, {"ranbir", "roshan", "siddu"})
    assert code == :bad
    assert message == "User you are trying to subscribe does not exist"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.registerUser(data, {"Mukul", "mehra"})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.deleteUser(data, {"Mukul", "mehra"})
    assert code == :ok
    assert message == "Success"


    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.subscribeUser(data, {"ranbir", "roshan", "Mukul"})
    assert code == :bad
    assert message == "User you are trying to subscribe does not exist"


    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.postTweet(data, {"sid", "jain", "sid's first tweet."})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.postTweet(data, {"jay", "patel", "Jay's first tweet."})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.postTweet(data, {"sid", "jain", "sid's second tweet."})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.getSubscribedTweets(data, {"ranbir", "roshan"})
    assert code == :ok
#    IO.inspect(message)
    assert message == "Success"
    end

  test "Get Tweets By HashTag" do
    {:ok, server_pid} = GenServer.start(TwitterLoadBalance, %{})

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.registerUser(data, {"ranbir", "roshan"})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.registerUser(data, {"jay", "patel"})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.postTweet(data, {"ranbir", "roshan", "My first tweet #cool."})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.getTweetsFromHashtags(data, "#cool")
    assert code == :ok
    assert Enum.count(message) == 1
    [{id, {posted_by, _a, tweet}}] = message
    assert posted_by == "ranbir"
    assert tweet == "My first tweet #cool."

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.getTweetsFromHashtags(data, "")
    assert code == :bad
    assert message == "Hashtag cannot be empty"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.getTweetsFromHashtags(data, "")
    assert code == :bad
    assert message == "Hashtag cannot be empty"


    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.postTweet(data, {"jay", "patel", "i am a #rockstar #cool."})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.getTweetsFromHashtags(data, "#cool")
    assert code == :ok
    assert Enum.count(message) == 2
    [{id1, {posted_by, _a, tweet}}, {id2, {posted_by_2, _b, tweet_2}}] = message
    assert posted_by == "ranbir"
    assert tweet == "My first tweet #cool."
    assert posted_by_2 == "jay"
    assert tweet_2 == "i am a #rockstar #cool."


    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.getTweetsFromHashtags(data, "#rockstar")
    assert code == :ok
    assert Enum.count(message) == 1
    [{id2, {posted_by_2, _b, tweet_2}}] = message
    assert posted_by_2 == "jay"
    assert tweet_2 == "i am a #rockstar #cool."
  end

  test "Get self mention" do
    {:ok, server_pid} = GenServer.start(TwitterLoadBalance, %{})

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.registerUser(data, {"ranbir", "roshan"})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.registerUser(data, {"sid", "jain"})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.registerUser(data, {"jay", "patel"})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.postTweet(data, {"ranbir", "roshan", "My first tweet #cool."})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.postTweet(data, {"jay", "patel", "i am a #rockstar #cool @ranbir."})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.getMyMentions(data, {"ranbir", "roshan"})
    assert code == :ok
    assert Enum.count(message) == 1
    [{id2, {posted_by_2, _b, tweet_2}}] = message
    assert posted_by_2 == "jay"
    assert tweet_2 == "i am a #rockstar #cool @ranbir."


    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.postTweet(data, {"sid", "jain", "what a good day @ranbir."})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.getMyMentions(data, {"ranbir", "roshan"})
    assert code == :ok
    assert Enum.count(message) == 2
    [{id2, {posted_by_2, _b, tweet_2}}, {id3, {posted_by_3, _a, tweet_3}}] = message
    assert posted_by_2 == "jay"
    assert tweet_2 == "i am a #rockstar #cool @ranbir."
    assert posted_by_3 == "sid"
    assert tweet_3 == "what a good day @ranbir."
  end

  test "Retweet Subscriber's tweets" do
    {:ok, server_pid} = GenServer.start(TwitterLoadBalance, %{})

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.registerUser(data, {"ranbir", "roshan"})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.registerUser(data, {"sid", "jain"})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.registerUser(data, {"jay", "patel"})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.postTweet(data, {"ranbir", "roshan", "My first tweet #cool."})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.postTweet(data, {"jay", "patel", "i am a #rockstar #cool @ranbir."})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.getMyMentions(data, {"ranbir", "roshan"})
    assert code == :ok
    assert Enum.count(message) == 1
    [{id2, {posted_by_2, _b, tweet_2}}] = message
    assert posted_by_2 == "jay"
    assert tweet_2 == "i am a #rockstar #cool @ranbir."

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.postTweet(data, {"sid", "jain", "what a good day @ranbir."})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.getTweetsFromHashtags(data, "#cool")
    assert code == :ok
    assert Enum.count(message) == 2
    [{id1, {posted_by, _a, tweet}}, {id2, {posted_by_2, _b, tweet_2}}] = message
    assert posted_by == "ranbir"
    assert tweet == "My first tweet #cool."
    assert posted_by_2 == "jay"
    assert tweet_2 == "i am a #rockstar #cool @ranbir."

    retweet = Enum.random(message)
    {id, {posted_by, _a, tweet}} = retweet
    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.retweet(data, {"ranbir", "roshan", id})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.getMyMentions(data, {"ranbir", "roshan"})
    assert code == :ok
    assert Enum.count(message) == 2
    [{id2, {posted_by_2, _b, tweet_2}}, {id3, {posted_by_3, _a, tweet_3}}] = message
    assert posted_by_2 == "jay"
    assert tweet_2 == "i am a #rockstar #cool @ranbir."
    assert posted_by_3 == "sid"
    assert tweet_3 == "what a good day @ranbir."

    retweet1 = Enum.random(message)
    {id, {posted_by, _a, tweet}} = retweet1
    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.retweet(data, {"ranbir", "roshan", id})
    assert code == :ok
    assert message == "Success"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response==:redirect
    {code, message} = TwitterProcessor.getMyRetweets(data, {"ranbir", "roshan"})
    assert code == :ok
#    IO.inspect(message, label: "RETWEETSSSSSSSSSSSSSSSSSSSSS")
    assert message == "Success"

  end

end