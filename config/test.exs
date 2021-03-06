use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :sleep_rescue, SleepRescue.Repo,
  username: "postgres",
  password: "postgres",
  database: "sleep_rescue_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sleep_rescue, SleepRescueWeb.Endpoint,
  http: [port: 4002],
  server: false

config :sleep_rescue, SleepRescue.Mail.Mailer,
  adapter: Bamboo.TestAdapter

# Print only warnings and errors during test
config :logger, level: :warn

config :pow, Pow.Ecto.Schema.Password, iterations: 1
