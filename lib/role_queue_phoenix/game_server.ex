defmodule RoleQueuePhoenix.GameServer do
  @moduledoc """
  A game server process that holds a `Game` struct as its state.
  """

  use GenServer

  require Logger

  @timeout :timer.hours(2)

  # Client (Public) Interface

  @doc """
  Spawns a new game server process registered under the given `game_name`.
  """
  def start_link(game_name) do
    GenServer.start_link(__MODULE__,
                         {game_name},
                         name: via_tuple(game_name))
  end

  def summary(game_name) do
    GenServer.call(via_tuple(game_name), :summary)
  end

  def assign_role(game_name, role, player) do
    GenServer.call(via_tuple(game_name), {:assign_role, role, player})
  end

  def add_player(game_name, player_id, player_name) do
    GenServer.call(via_tuple(game_name), {:add_player, player_id, player_name})
  end

  # @doc """
  # Returns a tuple used to register and lookup a game server process by name.
  # """
  def via_tuple(game_name) do
    {:via, Registry, {RoleQueuePhoenix.GameRegistry, game_name}}
  end

  # @doc """
  # Returns the `pid` of the game server process registered under the
  # given `game_name`, or `nil` if no process is registered.
  # """
  def game_pid(game_name) do
    game_name
    |> via_tuple()
    |> GenServer.whereis()
  end

  # # Server Callbacks

  def init({game_name}) do
    # case :ets.lookup(:games_table, game_name) do
    #   [] ->
    #     game = RoleQueuePhoenix.Game.new(game_name)
    #     :ets.insert(:games_table, {game_name, game})
    #     game

    #   [{^game_name, game}] ->
    #     game
    # end
    game = RoleQueuePhoenix.Game.new(game_name)

    Logger.info("Spawned game server process named '#{game_name}'.")

    {:ok, game, @timeout}
  end

  def handle_call(:summary, _from, game) do
    {:reply, game, game, @timeout}
  end

  def handle_call({:add_player, player_id, player_name}, _from, game) do
    game = RoleQueuePhoenix.Game.add_player(game, player_id, player_name)
    {:reply, game, game, @timeout}
  end

  def handle_call({:assign_role, role, player}, _from, game) do
    new_game = RoleQueuePhoenix.Game.assign_role(game, role, player)

    # :ets.insert(:games_table, {my_game_name(), new_game})

    {:reply, summarize(new_game), new_game, @timeout}
  end

  def summarize(game) do
    %{
      roles: game.roles,
      players: game.players,
      game_name: game.name
    }
  end

  # def handle_info(:timeout, game) do
  #   {:stop, {:shutdown, :timeout}, game}
  # end

  # def terminate({:shutdown, :timeout}, _game) do
  #   :ets.delete(:games_table, my_game_name())
  #   :ok
  # end

  # def terminate(_reason, _game) do
  #   :ok
  # end

  # defp my_game_name do
  #   Registry.keys(RoleQueuePhoenix.GameRegistry, self()) |> List.first
  # end
end
