defmodule RoleQueuePhoenix.Game do

  # @enforce_keys [:squares]
  defstruct name: nil, players: [], roles: []

  alias RoleQueuePhoenix.Game

  @doc """
  Creates a game with a players and roles setup.
  """
  def new(name) do
    %Game{name: name, players: [], roles: setup_roles()}
  end

  # def update_game(game, player, role) do
  #   game
  #    |> assign_role
  # end

  def assign_role(game, player, role) do

    %{game | players: []}
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
