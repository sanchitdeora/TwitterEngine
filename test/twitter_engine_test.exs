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

    {code, message} = TwitterProcessor.postTweet(data, {"ranbir", "roshan", "My first tweet."})

    # expect a redirect to actual data server
    assert response == :redirect

    {code, message} = TwitterProcessor.postTweet(data, {"ranir", "roshan", "My first tweet."})
    Logger.info("#{message}")
    #expect the data to be saved to database
    assert code == :bad
    assert message == "Invalid user id or password"

    {code, message} = TwitterProcessor.postTweet(data, {"ranir", "roshan", "My first tweet."})
    Logger.info("#{message}")
    #expect the data to be saved to database
    assert code == :bad
    assert message == "Invalid user id or password"

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
    assert message == "Your Username is invalid"

    {response, data} = TwitterLoadBalance.chooseProcessor(server_pid)
    assert response == :redirect
    {code, message} = TwitterProcessor.subscribeUser(data, {"ranbir", "rosan", "sid"})
    assert code == :bad
    assert message == "Invalid user id or password"

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
end
