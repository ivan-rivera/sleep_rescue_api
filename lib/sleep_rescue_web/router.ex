defmodule SleepRescueWeb.Router do
  use SleepRescueWeb, :router

  # TODO: create a new plug/pipeline to check if the user has confirmed their email
  # TODO: create a new endpoint to check whether the user has confirmed their email

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug SleepRescueWeb.ApiAuthPlug, otp_app: :sleep_rescue
  end

  pipeline :api_unconfirmed do
    plug Pow.Plug.RequireAuthenticated, error_handler: SleepRescueWeb.ApiAuthErrorHandler
  end

  pipeline :api_confirmed do
    plug SleepRescueWeb.ApiAuthConfirmationPlug, error_handler: SleepRescueWeb.ApiAuthErrorHandler
  end

  # unprotected routes
  scope "/api/v1", SleepRescueWeb.Api.V1, as: :api_v1 do
    pipe_through :api

    resources "/registration", UserController, singleton: true, only: [:create]
    resources "/session", SessionController, singleton: true, only: [:create, :delete]
    post "/session/renew", SessionController, :renew
    post "/password/reset", PasswordResetController, :reset
    patch "/password/update/:token", PasswordResetController, :update
    get "/confirm/:token", UserController, :confirm_email
  end

  scope "/api/v1", SleepRescueWeb.Api.V1, as: :api_v1 do
    pipe_through [:api, :api_unconfirmed]
    get "/confirmation/resend", UserController, :resend_email_confirmation
  end


  scope "/api/v1", SleepRescueWeb.Api.V1, as: :api_v1 do
    pipe_through [:api, :api_confirmed]
    resources "/user", UserController, singleton: true, only: [:show, :delete, :update]
  end

end

