defmodule RoleQueuePhoenix.Player do

  @derive {Jason.Encoder, only: [:name, :role, :id, :hero]}
  @enforce_keys [:name]
  defstruct [:name, role: "Undecided", id: nil, hero: "Undecided"]

  @doc """
  Creates a player with the given `name`.
  """
  def new(name, id) do
    %RoleQueuePhoenix.Player{name: name, id: id}
  end
end
