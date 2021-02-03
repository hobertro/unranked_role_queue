defmodule RoleQueuePhoenixWeb.Presence do
  use Phoenix.Presence,
    otp_app: :RoleQueuePhoenix,
    pubsub_server: RoleQueuePhoenix.PubSub
end
