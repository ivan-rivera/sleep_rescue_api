defmodule SleepRescue.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      SleepRescue.Repo,
      # Start the Telemetry supervisor
      SleepRescueWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SleepRescue.PubSub},
      # Start the Endpoint (http/https)
      SleepRescueWeb.Endpoint,
      {Pow.Postgres.Store.AutoDeleteExpired, [interval: :timer.hours(1)]},
      # Start a worker by calling: SleepRescue.Worker.start_link(arg)
      # {SleepRescue.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SleepRescue.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SleepRescueWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
