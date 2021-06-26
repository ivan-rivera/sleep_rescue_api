# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config
# TODO: check production/deployment checklist before deploying live

config :sleep_rescue,
  ecto_repos: [SleepRescue.Repo]

# Configures the endpoint
config :sleep_rescue, SleepRescueWeb.Endpoint,
  url: [host: "localhost"], # todo: change this in prod
  secret_key_base: (System.get_env("SECRET_KEY_BASE_SR") || raise "secret key base is missing"),
  render_errors: [view: SleepRescueWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: SleepRescue.PubSub,
  live_view: [signing_salt: (System.get_env("LIVE_VIEW_SALT_SR") || raise "LV secret is missing")]

# POW authentication
config :sleep_rescue, :pow,
  user: SleepRescue.Users.User,
  repo: SleepRescue.Repo,
  extensions: [PowResetPassword, PowEmailConfirmation],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :user_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
