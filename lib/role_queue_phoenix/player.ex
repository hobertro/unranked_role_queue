defmodule RoleQueuePhoenix.Player do

  @enforce_keys [:name]
  defstruct [:name]

  @doc """
  Creates a player with the given `name`.
  """
  def new(name) do
    %RoleQueuePhoenix.Player{name: name}
  end
end
