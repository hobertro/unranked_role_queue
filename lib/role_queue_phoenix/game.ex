defmodule RoleQueuePhoenix.Game do
  @derive {Jason.Encoder, only: [:name, :players, :roles]}
  defstruct name: nil, players: [], roles: []

  alias RoleQueuePhoenix.Game
  alias RoleQueuePhoenix.Player

  @doc """
  Creates a game with a players and roles setup.
  """
  def new(name) do
    roles = setup_roles()
    %Game{name: name, players: [], roles: roles}
  end

  def assign_role(game, role, player_id) do
    # assign player the role
    # set the role as assigned

    case find_player(game.players, player_id) do
      nil ->
        game
      player ->
        new_players = game.players |> Enum.map(&assign_role_to_player(&1, role, player_id))
        %Game{game | players: new_players}
    end
  end

  def assign_role_to_player(player, role, player_id) do
    case player.id == player_id do
      true -> %Player{player | role: role}
      false -> player
    end
  end

  def add_player(%Game{} = game, id, name) do
    case find_player(game.players, id) do
      nil ->
        %Game{game | players: [Player.new(name, id) | game.players]}

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
