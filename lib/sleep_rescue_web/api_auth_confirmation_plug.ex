defmodule SleepRescueWeb.ApiAuthConfirmationPlug do

  import Plug.Conn, only: [halt: 1]
  import SleepRescueWeb.Helpers, only: [json_error: 3]

  def init(options), do: options

  def call(conn, _opts) do
    error_message = "Please confirm your email before accessing this action"
    case conn.assigns.current_user do
      nil -> conn
      u ->
        confirmed = not is_nil(u.email_confirmed_at)
        no_email_change = is_nil(u.unconfirmed_email)
        if confirmed and no_email_change, do: conn, else: conn
          |> json_error(401, error_message)
          |> halt
    end
  end

end
