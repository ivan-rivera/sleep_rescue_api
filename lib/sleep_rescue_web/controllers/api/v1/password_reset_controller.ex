defmodule SleepRescueWeb.Api.V1.PasswordResetController do
  @moduledoc """
  Password reset controller
  """

  use SleepRescueWeb, :controller
  alias SleepRescueWeb.Helpers
  alias SleepRescue.Mail.{Email, Mailer}

  # TODO: link this action to email send out
  @doc """
  Generate a password reset token
  """
  @spec reset(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def reset(conn, params = %{"email" => email}) do
    case PowResetPassword.Plug.create_reset_token(conn, params) do
      {:ok, %{token: token}, _} ->
        email
        |> Email.welcome_email("hi!") # TODO change to reset email and change the message
        |> Mailer.deliver_later()
        json(conn, %{data: %{reset_token: token}})
      _ -> Helpers.json_error(conn, 404, "email not found")
    end
  end

  def reset(conn, _params), do: Helpers.json_error(conn, 400, "no email provided")


  @doc """
  Given a password reset token in the header, set a new password
  """
  @spec update(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def update(conn, params = %{"token" => token, "password" => _, "password_confirmation" => _}) do
    with  {:ok, conn} <- PowResetPassword.Plug.load_user_by_token(conn, token),
          {:ok, _, conn} <- PowResetPassword.Plug.update_user_password(conn, params) do
      json(conn, %{message: "success"})
    else
      {:error, conn} -> Helpers.json_error(conn, 401, "incorrect token")
      {:error, cs, conn} ->
        {reason, _} = cs.errors[:password]
        Helpers.json_error(conn, 500, "unable to update password", [reason])
    end
  end

  def update(conn, _params), do: Helpers.json_error(conn, 400, "malformed request")

end
