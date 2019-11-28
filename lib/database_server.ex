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

  def tweet(server, args) do
    GenServer.call(server, {:tweet, args})
  end

  def getTweet(server, args) do
    GenServer.call(server, {:getTweet, args})
  end

  def putHashtag(server, args) do
    GenServer.call(server, {:putHashtag, args})
  end

  def getHashtag(server, args) do
    GenServer.call(server, {:getHashtag, args})
  end


  # SERVER SIDE
  def init(var) do
    userTable = :ets.new(:userTable, [:set, :protected])
    tweetTable = :ets.new(:tweetTable, [:set, :protected])
    hashtagTable = :ets.new(:hashtagTable, [:set, :protected])
    state = %{:userTable => userTable, :tweetTable => tweetTable, :hashtagTable => hashtagTable, :tweetCountID => 0}
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

  def handle_call({:updateUser, user}, _from, state) do
    data = :ets.lookup(Map.fetch!(state, :userTable), Map.fetch!(user, :username))
    if Enum.count(data) > 0 do
      :ets.insert(Map.fetch!(state, :userTable), {Map.fetch!(user, :username), user})
      {:reply, {:ok, "Success"}, state}
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
    :ets.insert_new(Map.fetch!(state, :tweetTable), {tweet_id, tweet})
    {:reply, {:ok, tweet_id}, state}
  end

  def handle_call({:putHashtag, args}, _from, state) do
    {hash, tweet_id} = args
    data = :ets.lookup(Map.fetch!(state, :hashtagTable), hash)
    if Enum.count(data) > 0 do
      {hash, tweetList} = Enum.at(data, 0)
      :ets.insert(Map.fetch!(state, :hashtagTable), {hash, tweetList ++ [tweet_id]})
    else
      :ets.insert_new(Map.fetch!(state, :hashtagTable), {hash, [tweet_id]})
    end
    {:reply, {:ok, "Success"}, state}
  end

  def handle_call({:getHashtag, hashtag}, _from, state) do
    data = :ets.lookup(Map.fetch!(state, :hashtagTable), hashtag)
    if Enum.count(data) > 0 do
      {hash, tweetList} = Enum.at(data, 0)
      {:reply, {:ok, tweetList}, state}
    else
      {:reply, {:ok, []}, state}
    end
  end
end