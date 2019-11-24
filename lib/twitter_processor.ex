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

  def subscribeUser(server, args) do
    GenServer.call(server, {:subsribeUser, args})
  end

  def postTweet(server,args) do
    GenServer.call(server, {:postTweet, args})
  end

  # SERVER SIDE
  def init(opts) do
    state = %{:database => opts}
    {:ok, state}
  end

  def handle_call({:registerUser, args}, _from, state) do
    {username, password} = args
    username = String.downcase(username) |> String.trim()
    {code, message} = validateCredentials(username, password)

    if code == :ok do
      newUser = %{:username => username, :password => password, :tweets => [], :following => []}
      {code, message} = DatabaseServer.createUser(Map.fetch!(state, :database), newUser)
      {:reply, {code, message}, state}
    else
      {:reply, {code, message}, state}
    end
  end

  def handle_call({:loginUser, _name, _password}, _from, state) do
    {:reply, {:ok, "stub"}, state}
  end

  def handle_call({:postTweet, args}, _from, state) do
    {name, password, tweet} = args
    tweet = String.trim(tweet)
    if String.length(tweet) > 0 do

      {result, user} = DatabaseServer.getUser(Map.fetch!(state, :database), name)
      if result == :ok do
        if (validateUser(name, password, user)) do

          {:ok, tweet_id} = DatabaseServer.tweet(Map.fetch!(state, :database), tweet)

          tweets = Map.fetch!(user, :tweets)
          updateUserInfo = Map.replace!(user, :tweets, tweets ++ [tweet_id])
          {code, message} = DatabaseServer.updateUser(Map.fetch!(state, :database), updateUserInfo)
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

  def handle_call({:subscribeUser, username}, _from, state) do
    user = DatabaseServer.getUser()
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
      {:ok, "success"}
    else
      {:bad, label <> " cannot be empty"}
    end
  end

  def validateCredentials(name, password) do
    {code, error} = validateNonEmptyString(name, "Username")
    if code == :ok do
      validateNonEmptyString(password, "Password")
    else
      {code, error}
    end
  end

end