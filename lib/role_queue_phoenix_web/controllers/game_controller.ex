defmodule RoleQueuePhoenixWeb.GameController do
  use RoleQueuePhoenixWeb, :controller

  plug :require_player

  # alias RoleQueuePhoenixWeb.{GameServer, GameSupervisor}

  # @spec new(Plug.Conn.t(), any) :: Plug.Conn.t()
  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"game" => %{"name" => name}}) do
    case RoleQueuePhoenix.GameSupervisor.start_game(name) do
      {:ok, _game_pid} ->
        redirect(conn, to: Routes.game_path(conn, :show, name))

      {:error, error} ->
        conn
        |> put_flash(:error, "Unable to start game!")
        |> redirect(to: Routes.game_path(conn, :new))
    end
  end

  def show(conn, %{"id" => game_name}) do
    case RoleQueuePhoenix.GameServer.game_pid(game_name) do
      pid when is_pid(pid) ->
        conn
        |> assign(:game_name, game_name)
        |> assign(:auth_token, generate_auth_token(conn))
        |> assign(:user_tag, get_session(conn, :user_tag))
        |> render("show.html")

      nil ->
        conn
        |> put_flash(:error, "Game not found!")
        |> redirect(to: Routes.game_path(conn, :new))
    end
  end

  defp require_player(conn, _opts) do
    if get_session(conn, :current_player) do
      conn
    else
      conn
      |> put_session(:return_to, conn.request_path)
      |> redirect(to: RoleQueuePhoenixWeb.Router.Helpers.session_path(conn, :new))
      |> halt()
    end
  end

  defp generate_auth_token(conn) do
    current_player = get_session(conn, :current_player)
    Phoenix.Token.sign(conn, "player auth", current_player)
  end
end
