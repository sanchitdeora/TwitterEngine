defmodule TwitterProcessor do
  use GenServer

  # CLIENT SIDE
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  def registerUser(server, args) do
    GenServer.call(server, {:registerUser, args})
  end

  def loginUser(server) do
    GenServer.call(server, {:loginUser})
  end

  def deleteUser(server, args) do
    GenServer.call(server, {:deleteUser, args})
  end

  def subscribeUser(server, args) do
    GenServer.call(server, {:subscribeUser, args})
  end

  def getSubscribedTweets(server, args) do
    GenServer.call(server, {:getSubscribedTweets, args})
  end

  def postTweet(server,args) do
    GenServer.call(server, {:postTweet, args})
  end

  # SERVER SIDE
  def init(database_id) do
    state = database_id
    {:ok, state}
  end

  def handle_call({:registerUser, args}, _from, state) do
    {username, password} = args
    username = String.downcase(username) |> String.trim()
    {code, message} = validateCredentials(username, password)

    if code == :ok do
      newUser = %{:username => username, :password => password, :tweets => [], :following => [], :ifDeleted => false}
      {code, message} = DatabaseServer.createUser(state, newUser)
      {:reply, {code, message}, state}
    else
      {:reply, {code, message}, state}
    end
  end

  def handle_call({:loginUser, args}, _from, state) do
    {:reply, {:ok, "stub"}, state}
  end

  def handle_call({:deleteUser, args}, _from, state) do
    {username, password} = args
    username = String.trim(username) |> String.downcase()
    {code, message} = validateCredentials(username, password)
    if code == :bad do
      {:reply, {code, message}, state}
    end
    {result, user} = DatabaseServer.getUser(state, username)
    if result == :bad do
      {:reply, {result, user}, state}
    end
    if validateUser(username, password, user) == false do
      {:reply, {:bad, "Invalid user id or password"}, state}
    end

    updatedInfo = Map.replace!(user, :ifDeleted, true)
    {code, message} = DatabaseServer.updateUser(state, updatedInfo)
    {:reply, {code, message}, state}

  end

  def handle_call({:postTweet, args}, _from, state) do
    {username, password, tweet} = args
    tweet = String.trim(tweet)
    if String.length(tweet) > 0 do

      {result, user} = DatabaseServer.getUser(state, username)
      if result == :ok do
        if (validateUser(username, password, user)) do

          {:ok, tweet_id} = DatabaseServer.tweet(state, {username, DateTime.utc_now(), tweet})

          tweets = Map.fetch!(user, :tweets)
          updatedInfo = Map.replace!(user, :tweets, tweets ++ [tweet_id])
          {code, message} = DatabaseServer.updateUser(state, updatedInfo)
          {:reply, {code, message} , state}
        else
          {:reply, {:bad, "Invalid user id or password"}, state}
        end
      else
        {:reply, {:bad, "Invalid user id or password"}, state}
      end
    else
      {:reply, {:bad, "Tweets cannot be empty"}, state}
    end
  end

  def handle_call({:subscribeUser, args}, _from, state) do
    {myUsername, myPassword, usernameToSubscribe} = args
    myUsername = String.trim(myUsername) |> String.downcase()
    usernameToSubscribe = String.trim(usernameToSubscribe) |> String.downcase()
    {code1, message1} = validateCredentials(myUsername, myPassword)
    {code2, message2} = validateNonEmptyString(usernameToSubscribe, "Subscribing username")
    {myResult, myUser} = DatabaseServer.getUser(state, myUsername)
    {result2, userToSubscribe} = DatabaseServer.getUser(state, usernameToSubscribe)

    cond do
      code1 == :bad ->
        {:reply, {code1, message1}, state}
      code2 == :bad ->
        {:reply, {code2, message2}, state}
      myResult == :bad ->
        {:reply, {:bad, "Your Username is invalid"}, state}
      result2 == :bad || Map.fetch!(userToSubscribe, :ifDeleted) == true ->
        {:reply, {:bad, "User you are trying to subscribe does not exist"}, state}
      validateUser(myUsername, myPassword, myUser) == false ->
        {:reply, {:bad, "Invalid user id or password"}, state}
      true ->
        following = Map.fetch!(myUser, :following)
        if Enum.member?(following, usernameToSubscribe) do
          {:reply, {:bad, "Already Subscribed to user"}, state}
        else
          updatedInfo = Map.replace!(myUser, :following, following ++ [usernameToSubscribe])
          {code, message} = DatabaseServer.updateUser(state, updatedInfo)
          {:reply, {code, message}, state}
        end
    end
  end

  def handle_call({:getSubscribedTweets, args}, _from, state) do
    {username, password} = args
    username = String.trim(username) |> String.downcase()
    password = String.trim(password)
    {code, message} = validateCredentials(username, password)
    if code == :bad do
      {:reply, {code, message}, state}
    end
    {result, user} = DatabaseServer.getUser(state, username)
    if result == :bad do
      {:reply, {result, user}, state}
    end
    if validateUser(username, password, user) == false do
      {:reply, {:bad, "Invalid user id or password"}, state}
    end
    following = Map.fetch!(user, :following)
    subscribedTweets = Enum.map(following, fn subscribedUsername ->
      {result2, subscribedUser} = DatabaseServer.getUser(state, subscribedUsername)
      tweets =
        if Map.fetch!(subscribedUser, :ifDeleted) == false do
          tweet_ids = Map.fetch!(subscribedUser, :tweets)
           tweets = Enum.map(tweet_ids, fn curr_tid ->
            {code, tweet} = DatabaseServer.getTweet(state, curr_tid)
            tweet
          end)
           tweets
        else
          []
        end
    end)
    IO.inspect(List.flatten(subscribedTweets)|> Enum.sort_by(&(elem(&1, 1))))
    {:reply, {:ok, "Success"}, state}
  end



  def validateUser(name, password, userObject) do
    if (name == Map.fetch!(userObject, :username) && password == Map.fetch!(userObject, :password)) do
      true
    else
      false
    end
  end

  def validateNonEmptyString(data, label) do
    if String.length(String.trim(data)) > 0 do
      {:ok, "Success"}
    else
      {:bad, label <> " cannot be empty"}
    end
  end

  def validateCredentials(name, password) do
    {code, message} = validateNonEmptyString(name, "Username")
    if code == :ok do
      validateNonEmptyString(password, "Password")
    else
      {code, message}
    end
  end

end