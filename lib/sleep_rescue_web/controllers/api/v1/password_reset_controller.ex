defmodule SleepRescueWeb.Api.V1.PasswordResetController do
  @moduledoc """
  Password reset controller
  """

  use SleepRescueWeb, :controller
  alias SleepRescueWeb.Helpers
  alias SleepRescue.Mail.Mailer
  alias SleepRescue.Email

  @doc """
  Generate a password reset token
  """
  @spec reset(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def reset(conn, params = %{"email" => email}) do
    case PowResetPassword.Plug.create_reset_token(conn, params) do
      {:ok, %{token: token}, _} ->
        case email
          |> Email.reset_email(token) # TODO look into timeouts
          |> Mailer.deliver_later() do
            {:ok, _} -> json(conn, %{data: %{message: "message sent"}})
            _ -> Helpers.json_error(conn, 500, "unable to send the message")
        end
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
      json(conn, %{data: %{email: conn.assigns.reset_password_user.email, message: "success"}})
    else
      _ -> Helpers.json_error(conn, 500, "unable to update password")
    end
  end

  def update(conn, _params), do: Helpers.json_error(conn, 400, "malformed request")

end
