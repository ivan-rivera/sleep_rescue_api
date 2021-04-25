defmodule SleepRescueWeb.Helpers do
  @moduledoc """
  Controller helper functions
  """
  use SleepRescueWeb, :controller

  def json_error(conn, status, message, errors \\ []) do
    conn
    |> put_status(status)
    |> json(%{error: %{message: message, errors: errors}})
  end

end
