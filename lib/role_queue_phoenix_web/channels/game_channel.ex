defmodule RoleQueuePhoenixWeb.GameChannel do
  use RoleQueuePhoenixWeb, :channel

  alias RoleQueuePhoenixWeb.Presence
  alias RoleQueuePhoenix.GameServer
  alias RoleQueuePhoenix.Game

  @spec join(<<_::48, _::_*8>>, any, any) :: {:error, %{reason: <<_::152>>}} | {:ok, any}
  def join("games:" <> game_name, params, socket) do
    case GameServer.game_pid(game_name) do
      pid when is_pid(pid) ->
        send(self(), {:after_join, game_name, params["userTag"]})
        {:ok, socket}

      nil ->
        {:error, %{reason: "Game does not exist"}}
    end
  end

  @spec handle_info({:after_join, any, any}, Phoenix.Socket.t()) :: {:noreply, Phoenix.Socket.t()}
  def handle_info({:after_join, game_name, player_id}, socket) do
    player_name = current_player(socket).name
    summary     = GameServer.add_player(game_name, player_id, player_name)

    # push(socket, "game_summary", summary)
    broadcast!(socket, "game_summary", summary)
    {:noreply, socket}
  end

  def handle_in("assign_role", body, socket) do
    player_name = current_player(socket).name
    IO.inspect body
    # summary     = GameServer.assign_role(game_name, player_id, player_name)
    # broadcast!(socket, "new_chat_message", %{
    #   name: current_player(socket).name,
    #   body: body
    # })

    {:noreply, socket}
  end

  defp current_player(socket) do
    socket.assigns.current_player
  end
end
