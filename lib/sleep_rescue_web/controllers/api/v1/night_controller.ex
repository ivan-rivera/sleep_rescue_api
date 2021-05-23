defmodule SleepRescueWeb.Api.V1.NightController do
  @moduledoc """
  Controllers for interacting with nights
  """

  use SleepRescueWeb, :controller
  alias SleepRescue.Users.Night
  alias Plug.Conn
  import SleepRescueWeb.Helpers, only: [json_error: 3]


  @doc """
  Show summary for a range of nights
  """
  @spec show(Conn.t(), map()) :: Conn.t()
  def show(conn, %{"history" => history}) do
    case Night.list_nights(conn.assigns.current_user, n_days_back: history+1) do
      [] -> json(conn, %{message: "no data", data: []})
      nights ->
        data = nights |> Enum.map(&Night.summarise_night/1)
        json(conn, %{message: "success", data: data})
    end
  end


  @doc """
  Create or update a night
  """
  @spec update(Conn.t(), map()) :: Conn.t()
  def update(conn, %{"date" => date, "night" => night_params}) do
    case Night.create_or_update(conn.assigns.current_user, date, night_params) do
      {:ok, _} -> json(conn, %{message: "success"})
      {:error, _} -> json_error(conn, 500, "failed to update")
    end
  end

end
