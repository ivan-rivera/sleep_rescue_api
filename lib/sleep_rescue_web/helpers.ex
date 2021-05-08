defmodule SleepRescueWeb.Helpers do
  @moduledoc """
  Controller helper functions
  """
  use SleepRescueWeb, :controller
  alias SleepRescue.Mail.Mailer
  alias SleepRescue.Email
  alias Plug.Conn

  def json_error(conn, status, message, errors \\ []) do
    conn
    |> put_status(status)
    |> json(%{error: %{message: message, errors: errors}})
  end

  @spec send_confirmation_email(Conn.t(), map()) :: Conn.t()
  def send_confirmation_email(conn, user) do
    token = PowEmailConfirmation.Plug.sign_confirmation_token(conn, user)
    case (user.unconfirmed_email || user.email)
         |> Email.confirmation_email(token)
         |> Mailer.deliver_later() do
      {:ok, _} -> json(conn, %{message: "message sent"})
      _ -> json_error(conn, 500, "unable to send the message")
    end
  end

end
