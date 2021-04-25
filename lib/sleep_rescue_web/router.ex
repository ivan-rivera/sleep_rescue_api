defmodule SleepRescueWeb.Router do
  use SleepRescueWeb, :router

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

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

    resources "/registration", UserController, singleton: true, only: [:create]
    resources "/session", SessionController, singleton: true, only: [:create, :delete]
    post "/session/renew", SessionController, :renew
    post "/password/reset", PasswordResetController, :reset
    patch "/password/update/:token", PasswordResetController, :update
  end

  # protected routes
  scope "/api/v1", SleepRescueWeb.Api.V1, as: :api_v1 do
    pipe_through [:api, :api_protected]
    resources "/user", UserController, singleton: true, only: [:show, :delete, :update]
  end

end
