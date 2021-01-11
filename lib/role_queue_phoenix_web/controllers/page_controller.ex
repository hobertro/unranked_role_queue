defmodule RoleQueuePhoenixWeb.PageController do
  use RoleQueuePhoenixWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
