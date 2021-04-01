defmodule SleepRescueWeb.Router do
  use SleepRescueWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug SleepRescueWeb.ApiAuthPlug, otp_app: :sleep_rescue
  end

  pipeline :api_protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: SleepRescueWeb.ApiAuthErrorHandler
  end

  # unprotected routes
  scope "/api/v1", SleepRescueWeb.Api.V1, as: :api_v1 do
    pipe_through :api

    resources "/registration", RegistrationController, singleton: true, only: [:create]
    resources "/session", SessionController, singleton: true, only: [:create, :delete]
    post "/session/renew", SessionController, :renew
  end

  # protected routes
  scope "/api/v1", SleepRescueWeb.Api.V1, as: :api_v1 do
    pipe_through [:api, :api_protected]
  end

end
