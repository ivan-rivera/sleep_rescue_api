defmodule SleepRescueWeb.Api.V1.ContactController do
  @moduledoc """
  Controllers for sending contact messages
  """

  use SleepRescueWeb, :controller
  alias SleepRescue.Mail.Mailer
  alias SleepRescue.Email
  import SleepRescueWeb.Helpers, only: [json_error: 3]

  @doc """
  Send a contact form to the designated email
  """
  def send(conn, %{"user" => user, "text" => text}) do
    case Email.contact_email(text, user) |> Mailer.deliver_later() do
      {:ok, _} -> json(conn, %{message: "message sent"})
      {:error, x} ->
        IO.inspect(x)
        json_error(conn, 500, "unable to send the message")
    end
  end

end
