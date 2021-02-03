defmodule RoleQueuePhoenix.Game do
  @derive {Jason.Encoder, only: [:name, :players, :roles]}
  defstruct name: nil, players: [], roles: []

  alias RoleQueuePhoenix.Game
  alias RoleQueuePhoenix.Player

  @doc """
  Creates a game with a players and roles setup.
  """
  def new(name) do
    %Game{name: name, players: [], roles: setup_roles()}
  end

  def assign_role(game, player, role) do
    %{game | players: []}
  end

  def add_player(%Game{} = game, id, name) do
    case find_player(game.players, id) do
      nil ->
        %Game{game | players: [Player.new(id, name) | game.players]}

      player ->
        # players = replace(game.players, id, fn player -> %Player{ player | name: name} end)

        # %Game{game | players: players}
        game
    end
  end

  def find_player(players, id) do
    result = Enum.filter(players, fn existing_player -> id == existing_player.id end)

    case result do
      [] -> nil
      [player] -> player
    end
  end

  def setup_roles do
    roles  = ["Carry", "Mid", "Offlane", "(Offlane) Support", "(Hard) Support"]
    Enum.with_index(roles)
     |> Enum.map(fn({role_name, index}) ->
      %RoleQueuePhoenix.Role{
        name: role_name,
        position: index + 1,
        reserved: false
      }
    end)
  end
end
