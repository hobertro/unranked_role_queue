defmodule RoleQueuePhoenix.Repo do
  use Ecto.Repo,
    otp_app: :role_queue_phoenix,
    adapter: Ecto.Adapters.Postgres
end
