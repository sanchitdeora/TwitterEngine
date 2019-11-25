defmodule UserDataServerTest do
  use ExUnit.Case
  doctest DatabaseServer

  test "CreateUser" do
    {:ok, server_pid} = GenServer.start(DatabaseServer, %{})
    newUser = %{username: "", password: "roshan"}
    {ret, _reason} = GenServer.call(server_pid, {:createUser, newUser})
    assert ret == :ok
    newUser = %{username: "ranbira", password: ""}
    {ret, _reason} = GenServer.call(server_pid, {:createUser, newUser})
    assert ret == :ok
    newUser = %{username: "ranbir", password: "roshan"}
    {ret, reason} = GenServer.call(server_pid, {:createUser, newUser})
    assert ret == :ok
    assert reason == "Success"
    {ret, reason} = GenServer.call(server_pid, {:createUser, newUser})
    assert ret == :bad
    assert reason == "Username already in use"

  end

  test "DeleteUser" do
    {:ok, server_pid} = GenServer.start(DatabaseServer, %{})
    {ret, reason} = GenServer.call(server_pid, {:deleteUser, "Ranbie"})
    assert ret == :bad
    assert reason == "Invalid User ID"
    newUser = %{username: "ranbir", password: "roshan"}
    {ret, reason} = GenServer.call(server_pid, {:createUser, newUser})
    assert ret == :ok
    assert reason == "Success"
    {ret, reason} = GenServer.call(server_pid, {:deleteUser, "Ranbir"})
    assert ret == :bad
    assert reason == "Invalid User ID"
    {ret, reason} = GenServer.call(server_pid, {:deleteUser, "ranbir"})
    assert ret == :ok
    assert reason == "Success"
    {ret, reason} = GenServer.call(server_pid, {:createUser, newUser})
    assert ret == :ok
    assert reason == "Success"
  end
end