defmodule RoleQueuePhoenix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    # List all child processes to be supervised
    children = [
      {Registry, keys: :unique, name: RoleQueuePhoenix.GameRegistry},
      # Start the Ecto repository
      # RoleQueuePhoenix.Repo,
      # Start the endpoint when the application starts
      HeroCacheServer,
      RoleQueuePhoenixWeb.Endpoint,
      RoleQueuePhoenix.GameSupervisor,
      supervisor(RoleQueuePhoenixWeb.Presence, [])
      # Starts a worker by calling: RoleQueuePhoenix.Worker.start_link(arg)
      # {RoleQueuePhoenix.Worker, arg},
    ]

    # :ets.new(:games_table, [:public, :named_table])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RoleQueuePhoenix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RoleQueuePhoenixWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
