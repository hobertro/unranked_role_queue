defmodule RoleQueuePhoenix.Hero do
  @derive {Jason.Encoder, only: [:name, :image_url, :hero_roles]}
  defstruct name: nil, image_url: [], hero_roles: []

  alias RoleQueuePhoenix.Hero

  @doc """
  Creates a hero
  """
  def new(name, hero_roles) do
    image_url = construct_url(name)
    %RoleQueuePhoenix.Hero{name: name, image_url: image_url, hero_roles: hero_roles}
  end

  @spec construct_url(binary) :: <<_::64, _::_*8>>
  def construct_url(name) do
    name = String.downcase(name)
    "https://steamcdn-a.akamaihd.net/apps/dota2/images/heroes/#{name}_sb.png"
  end
end
