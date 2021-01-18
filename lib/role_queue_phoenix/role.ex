defmodule RoleQueuePhoenix.Role do

  @enforce_keys [:name]
  defstruct [:name, :position, :reserved]

  @doc """
  Creates a role with the given `name`, position, reservation.
  """
  def new(name, position, reserved) do
    %RoleQueuePhoenix.Role{name: name, position: position, reserved: reserved}
  end
end
