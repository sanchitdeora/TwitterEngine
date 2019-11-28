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

  def postTweet(server,args) do
    GenServer.call(server, {:postTweet, args})
  end

  def getTweetsFromHashtags(server, args) do
    GenServer.call(server, {:getTweetsFromHashtags, args})
  end

  def getMyMentions(server, args) do
    GenServer.call(server, {:getMyMentions, args})
  end

  def getSubscribedTweets(server, args) do
    GenServer.call(server, {:getSubscribedTweets, args})
  end

  # SERVER SIDE
  def init(database_id) do
    state = database_id
    {:ok, state}
  end

  def handle_call({:registerUser, args}, _from, state) do
    {username, password} = args
    username = String.downcase(username) |> String.trim()
    {code, message} = ifCredentialsNonEmpty(username, password)

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

    {code, message} = credentialCheck(username, password, state)
    cond do
      code == :bad ->
        {:reply, {code, message}, state}
      true ->
        {result, user} = DatabaseServer.getUser(state, username)
        updatedInfo = Map.replace!(user, :ifDeleted, true)
        {code, message} = DatabaseServer.updateUser(state, updatedInfo)
        {:reply, {code, message}, state}
    end
  end

  def handle_call({:postTweet, args}, _from, state) do
    {username, password, tweet} = args
    username = String.trim(username) |> String.downcase()
    tweet = String.trim(tweet)
    mentionsRegex = ~r/\@\w+/
    hashtagRegex = ~r/\#\w+/
    {code1, message1} = credentialCheck(username, password, state)
    {code2, message2} = ifStringNonEmpty(tweet, "Tweets")
    cond do
      code1 == :bad -> {:reply, {code1, message1} , state}
      code2 == :bad -> {:reply, {code2, message2} , state}
      true ->

        {result, user} = DatabaseServer.getUser(state, username)
        {:ok, tweet_id} = DatabaseServer.tweet(state, {username, DateTime.utc_now(), tweet})

        mentionsList = List.flatten(Regex.scan(mentionsRegex,tweet))
        hashtagList = List.flatten(Regex.scan(hashtagRegex,tweet))
        Enum.each(hashtagList, fn hashtag ->
#          IO.inspect(hashtag, label: "Strong hashtag")
          DatabaseServer.putHashtag(state, {hashtag, tweet_id})
        end)

        tweets = Map.fetch!(user, :tweets)
        updatedInfo = Map.replace!(user, :tweets, tweets ++ [tweet_id])
        {code, message} = DatabaseServer.updateUser(state, updatedInfo)
        {:reply, {code, message} , state}
    end
  end

  def handle_call({:subscribeUser, args}, _from, state) do
    {myUsername, myPassword, usernameToSubscribe} = args
    myUsername = String.trim(myUsername) |> String.downcase()
    usernameToSubscribe = String.trim(usernameToSubscribe) |> String.downcase()
    {myResult, myUser} = DatabaseServer.getUser(state, myUsername)
    {result2, userToSubscribe} = DatabaseServer.getUser(state, usernameToSubscribe)

    {code1, message1} = credentialCheck(myUsername, myPassword, state)
    {code2, message2} = credentialCheck(usernameToSubscribe, state)
    cond do
      code1 == :bad ->
        {:reply, {code1, message1}, state}

      code2 == :bad ->
        {:reply, {code2, message2}, state}

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
    {code, message} = credentialCheck(username, password, state)
    cond do
      code == :bad ->
        {:reply, {code, message}, state}
      true ->
        {result, user} = DatabaseServer.getUser(state, username)
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
  end

  def handle_call({:getTweetsFromHashtags, tag}, _from, state) do
    {code, message} = ifStringNonEmpty(tag, "Hashtag")
    cond do
      code == :bad -> {:reply, {code, message}, state}
      String.at(tag, 0) != "#" -> {:reply, {:bad, "Hashtag must begin with hash."}, state}
      true ->
        {code, tweetIDList} = DatabaseServer.getHashtag(state, tag)
        tweets = Enum.map(tweetIDList, fn curr_tid ->
          {code, tweet} = DatabaseServer.getTweet(state, curr_tid)
          tweet
        end)
        ret = List.flatten(tweets)|> Enum.sort_by(&(elem(&1, 1)))
        IO.inspect(ret)
        {:reply, {:ok, ret}, state}
    end
  end

  def validateUser(name, password, userObject) do
    if (name == Map.fetch!(userObject, :username) && password == Map.fetch!(userObject, :password)) do
      true
    else
      false
    end
  end

  def ifStringNonEmpty(data, label) do
    if String.length(String.trim(data)) > 0 do
      {:ok, "Success"}
    else
      {:bad, label <> " cannot be empty"}
    end
  end

  def ifCredentialsNonEmpty(name, password) do
    {code, message} = ifStringNonEmpty(name, "Username")
    if code == :ok do
      ifStringNonEmpty(password, "Password")
    else
      {code, message}
    end
  end

  def credentialCheck(username, state) do
    #    Check if username and password is not an empty string
    {code1, message1} = ifStringNonEmpty(username, "Subscribing username")
    #    Check if user exists or not
    {code2, user} = DatabaseServer.getUser(state, username)
    {code, message} = cond do
      code1 == :bad ->
        {code1, message1}
      (code2 == :bad || Map.fetch!(user, :ifDeleted) == true) ->
        {:bad, "User you are trying to subscribe does not exist"}
      true -> {:ok, "Valid"}
    end
    {code, message}
  end

  def credentialCheck(username, password, state) do
#    Check if username and password is not an empty string
    {code1, message1} = ifCredentialsNonEmpty(username, password)
#    Check if user exists or not
    {code2, user} = DatabaseServer.getUser(state, username)
    {code, message} = cond do
      code1 == :bad ->
        {code1, message1}
      code2 == :bad || Map.fetch!(user, :ifDeleted) == true ->
        {code2, "Invalid User ID"}
#     Check if username and password is correct
      validateUser(username, password, user) == false ->
        {:bad, "Invalid user id or password"}
      true -> {:ok, "Valid"}
    end
    {code, message}
  end

end