# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :role_queue_phoenix,
  ecto_repos: [RoleQueuePhoenix.Repo]

# Configures the endpoint
config :role_queue_phoenix, RoleQueuePhoenixWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pT0/WjQ7YvyqoWmXR04GzM/VWen+0amYeaW4VIkgMdP6nlN1zSyCz9zzPT3shrzf",
  render_errors: [view: RoleQueuePhoenixWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: RoleQueuePhoenix.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "rc3f2x5Y"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
