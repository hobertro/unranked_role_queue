defmodule HeroCacheServer do

  @name :hero_cache_server
  @refresh_interval :timer.minutes(60)

  use GenServer

  def init(_state) do
    {:ok, response} = DataScraper.get_data
    schedule_refresh()

    {:ok, response}
  end

  def start_link(_arg) do
    IO.puts "Starting the hero cache server"
    GenServer.start(__MODULE__, %{}, name: @name)
  end

  def handle_info(:refresh, _state) do
    IO.puts "refreshing the cache...."
    {:ok, response} = DataScraper.get_data
    schedule_refresh()

    {:noreply, response}
  end

  defp schedule_refresh do
    Process.send_after(self(), :refresh, @refresh_interval)
  end

  def handle_call(:recent_data, _from, state) do
    {:reply, state, state}
  end
end
