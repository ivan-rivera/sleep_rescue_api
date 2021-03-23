defmodule SleepRescue.Repo do
  use Ecto.Repo,
    otp_app: :sleep_rescue,
    adapter: Ecto.Adapters.Postgres
end
