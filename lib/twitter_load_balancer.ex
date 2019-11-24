defmodule TwitterLoadBalance do
  use GenServer

  # CLIENT SIDE
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def chooseProcessor(server) do
    GenServer.call(server, {:chooseProcessor})
  end

  # SERVER SIDE
  def init(init_arg) do
    processorCount = 5
    {:ok, db_pid} = DatabaseServer.start_link([])

    processerList =
      for i <- 1..processorCount do
        {:ok, pid} = TwitterProcessor.start_link(db_pid)
        pid
      end

    state = %{ :processors => processerList, :processorCount => processorCount, :lastServerUsed => 0 }
    {:ok, state}
  end

  def handle_call({:chooseProcessor}, _from, state) do
    nextProcessorIndex = rem(Map.fetch!(state, :lastServerUsed), Map.fetch!(state, :processorCount))
    Map.replace!(state, :lastServerUsed, nextProcessorIndex)
    processerList = Map.fetch!(state, :processors)
    next_pid = Enum.at(processerList, nextProcessorIndex)
    {:reply, {:redirect, next_pid}, state}
  end

end