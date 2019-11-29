defmodule Proj4 do

  # Accept Number of Users and Number of Tweets as arguments
  [num_user, num_msg] = System.argv
  {num_user, _} = Integer.parse(num_user)
  {num_msg, _} = Integer.parse(num_msg)

  Process.register(self(), Main)

  # Start Twitter Engine
  {:ok, server_pid} = TwitterEngine.start_link([])
  userlist = Utility.getUserCredentials(num_user)

  usernameList = Enum.map(userlist, fn user ->
    {username, password} = user
    username
  end)

  client_ids = Enum.map(0..(num_user - 1), fn userid ->
    credentials = Enum.at(userlist, userid)
    {username, password} = credentials
    Client.start_link({server_pid, userid, credentials, List.delete(usernameList, username), num_msg})
  end)

  Enum.map(client_ids, fn curr ->
    {:ok, client_id} = curr
    ret = Client.createAccount(client_id, client_id)
  end)

  Enum.map(client_ids, fn curr ->
    {:ok, client_id} = curr
    Process.sleep(1000)
    _state_after_exec = :sys.get_state(client_id, :infinity)
  end)
#  Utility.generateRandomTweet(70, usernameList)

  {_, t1} = :erlang.statistics(:wall_clock)
  IO.puts "Time taken to complete the simulation is #{t1} milliseconds"

end