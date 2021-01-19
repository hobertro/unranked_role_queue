defmodule RoleQueuePhoenixWeb.GameView do
  use RoleQueuePhoenixWeb, :view

  # def current_game_url(conn) do
  #   url(conn) <> conn.request_path
  # end

  def ws_url do
    System.get_env("WS_URL") || RoleQueuePhoenixWeb.Endpoint.config(:ws_url)
  end
end
