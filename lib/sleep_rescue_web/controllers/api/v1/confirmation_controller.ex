defmodule SleepRescueWeb.Api.V1.ConfirmationController do
  @moduledoc """
  Controllers for confirming an account
  """

  use SleepRescueWeb, :controller
  alias Plug.Conn
  alias SleepRescue.Users.User
  import SleepRescueWeb.Helpers, only: [json_error: 3, send_confirmation_email: 2]
  import PowEmailConfirmation.Ecto.Context, only: [confirm_email: 3]
  import PowEmailConfirmation.Plug, only: [load_user_by_token: 2]
  require Logger

  @doc """
  Given a confirmation token, mark that that the user has confirmed their email
  """
  @spec confirm_email(Conn.t(), map()) :: Conn.t()
  def confirm_email(conn, %{"token" => token}) do
    with  {:ok, conn}  <- load_user_by_token(conn, token),
          {:ok, _user} <- confirm_email(conn.assigns.confirm_email_user, %{}, otp_app: :sleep_rescue) do
      json(conn, %{email: conn.assigns.confirm_email_user.email, message: "Email confirmed"})
    else
      _ ->
        Logger.error("invalid confirmation code")
        json_error(conn, 401, "Invalid confirmation code")
    end
  end


  @doc """
  Allow users to request another confirmation email in case they didnt receive the first one
  """
  @spec resend_email_confirmation(Conn.t(), map()) :: Conn.t()
  def resend_email_confirmation(conn, _params) do
    send_confirmation_email(conn, conn.assigns.current_user)
  end


  @doc """
  Check whether users email has been confirmed or not
  """
  @spec get_confirmation_status(Conn.t(), map()) :: Conn.t()
  def get_confirmation_status(conn, _params) do
    with user = %User{email_confirmed_at: _, unconfirmed_email: _} <- conn.assigns.current_user,
         confirmed <- not is_nil(user.email_confirmed_at),
         no_email_change <- is_nil(user.unconfirmed_email) do
      json(conn, %{email_is_confirmed: confirmed and no_email_change})
    else
      _ -> json_error(conn, 500, "server error")
    end
  end

  end
