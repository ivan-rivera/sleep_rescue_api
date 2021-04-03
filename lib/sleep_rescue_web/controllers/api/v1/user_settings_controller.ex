defmodule SleepRescueWeb.Api.V1.UserSettingsController do
  use SleepRescueWeb, :controller

  def show(conn, _params) do
    json(conn, %{user: Pow.Plug.current_user(conn)})
  end

end
