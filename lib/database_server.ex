defmodule DatabaseServer do
  use GenServer

  # CLIENT SIDE
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def createUser(server, args) do
    GenServer.call(server, {:createUser, args})
  end

  def deleteUser(server, args) do
    GenServer.call(server, {:deleteUser, args})
  end

  def updateUser(server, args) do
    GenServer.call(server, {:updateUser, args})
  end

  def getUser(server, args) do
    GenServer.call(server, {:getUser, args})
  end

  def getTweet(server, args) do
    GenServer.call(server, {:getTweet, args})
  end

  def tweet(server, args) do
    GenServer.call(server, {:tweet, args})
  end

  # SERVER SIDE
  def init(var) do
    userTable = :ets.new(:user_lookup, [:set, :protected])
    tweetTable = :ets.new(:tweet_lookup, [:set, :protected])
    state = %{:userTable => userTable, :tweetTable => tweetTable, :tweetCountID => 0}
    {:ok, state}
  end

  def handle_call({:createUser, userData}, _from, state) do

    is_new = :ets.insert_new(Map.fetch!(state, :userTable), {Map.fetch!(userData, :username), userData})
    if is_new do
      {:reply, {:ok, "Success"}, state}
    else
      {:reply, {:bad, "Username already in use"}, state}
    end
  end

  def handle_call({:deleteUser, username}, _from, state) do
    #IO.inspect(username)
    data = :ets.lookup(Map.fetch!(state, :userTable), username)
    if Enum.count(data) > 0 do
      :ets.delete(Map.fetch!(state, :userTable), username)
      {:reply, {:ok, "Success"}, state}
    else
      {:reply, {:bad, "Invalid User ID"}, state}
    end
  end

  def handle_call({:getUser, username}, _from, state) do
    data = :ets.lookup(Map.fetch!(state, :userTable), username)
    if Enum.count(data) > 0 do
      {_id, user} = Enum.at(data, 0)
      {:reply, {:ok, user}, state}
    else
      {:reply, {:bad, "Invalid User ID"}, state}
    end
  end

  def handle_call({:getTweet, tweet_id}, _from, state) do
    [{tweet_id, tweet}] = :ets.lookup(Map.fetch!(state, :tweetTable), tweet_id)
    {:reply, {:ok, tweet}, state}
  end

  def handle_call({:tweet, tweet}, _from, state) do
    tweet_id = Map.fetch!(state, :tweetCountID)
    state = Map.replace!(state, :tweetCountID, tweet_id + 1)
    :ets.insert_new(Map.fetch!(state, :tweetTable), {tweet_id,tweet})
    {:reply, {:ok, tweet_id}, state}
  end

  def handle_call({:updateUser, user}, _from, state) do
    data = :ets.lookup(Map.fetch!(state, :userTable), Map.fetch!(user, :username))
    if Enum.count(data) > 0 do
      :ets.insert(Map.fetch!(state, :userTable), {Map.fetch!(user, :username), user})
      {:reply, {:ok, "Success"}, state}
    else
      {:reply, {:bad, "Invalid User ID"}, state}
    end
  end
end