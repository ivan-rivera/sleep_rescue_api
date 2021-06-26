defmodule SleepRescueWeb.Api.V1.NightController do
  @moduledoc """
  Controllers for interacting with nights
  """

  use SleepRescueWeb, :controller
  alias SleepRescue.Users.Night
  alias Plug.Conn
  import SleepRescueWeb.Helpers, only: [json_error: 4]
  require Logger

  @doc """
  Show summary for a range of nights
  """
  @spec show(Conn.t(), map()) :: Conn.t()
  def show(conn, %{"history" => history}) do
    {history_int, ""} = Integer.parse(history)
    case Night.list_nights(conn.assigns.current_user, history_int+1) do
      [] -> json(conn, %{"data" => %{}})
      nights ->
        data = nights
               |> Enum.map(&Night.summarise_night/1)
               |> Enum.into(%{})
        json(conn, %{"data" => data})
    end
  end


  @doc """
  Create or update a night
  """
  @spec update(Conn.t(), map()) :: Conn.t()
  def update(conn, %{"date" => date, "night" => night_params}) when is_map(night_params) do
    Logger.metadata(user_id: conn.assigns.current_user.id)
    case Night.create_or_update(conn.assigns.current_user, date, night_params) do
      {:ok, _} ->
        json(conn, %{message: "success"})
      {:error, cs} ->
        errors = cs.errors
                 |> Enum.into(%{})
                 |> Enum.map(fn {key, {message, _}} -> "#{Atom.to_string(key)}: #{message}" end)
        Logger.info("failed to update a night with errors: #{errors}")
        json_error(conn, 400, "input error", errors)
      _ ->
        Logger.info("Failed to update a night with server error")
        json_error(conn, 500, "server error", [])
    end
  end

end
