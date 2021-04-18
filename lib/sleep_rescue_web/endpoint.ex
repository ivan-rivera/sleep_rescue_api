defmodule SleepRescueWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :sleep_rescue

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_sleep_rescue_key",
    signing_salt: (System.get_env("SIGNING_SALT_SR") || raise "signing salt not found")
  ]

  socket "/socket", SleepRescueWeb.UserSocket,
    websocket: true,
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :sleep_rescue,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :sleep_rescue
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  plug Corsica,
    origins: ["http://localhost:8000", "http://192.168.0.11:8000"],
    allow_credentials: true,
    allow_headers: ["Content-Type", "Authorization", "Access-Control-Allow-Origin"],
    log: [rejected: :error, invalid: :warn, accepted: :debug]

  plug SleepRescueWeb.Router
end
