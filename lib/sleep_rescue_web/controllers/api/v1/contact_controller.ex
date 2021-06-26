defmodule SleepRescueWeb.Api.V1.ContactController do
  @moduledoc """
  Controllers for sending contact messages
  """

  use SleepRescueWeb, :controller
  alias SleepRescue.Mail.Mailer
  alias SleepRescue.Email
  import SleepRescueWeb.Helpers, only: [json_error: 3]
  require Logger

  @doc """
  Send a contact form to the designated email
  """
  def send(conn, %{"user" => user, "text" => text}) do
    case Email.contact_email(text, user) |> Mailer.deliver_later() do
      {:ok, _} -> json(conn, %{message: "message sent"})
      {:error, err} ->
        Logger.info("Failed to send a contact message: #{err.message}")
        json_error(conn, 500, "unable to send the message")
    end
  end

end
