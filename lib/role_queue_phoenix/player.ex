defmodule RoleQueuePhoenix.Player do

  @derive {Jason.Encoder, only: [:name, :role, :id]}
  @enforce_keys [:name]
  defstruct [:name, role: "Undecided", id: nil]

  @doc """
  Creates a player with the given `name`.
  """
  def new(name, id) do
    %RoleQueuePhoenix.Player{name: name, id: id}
  end
end
