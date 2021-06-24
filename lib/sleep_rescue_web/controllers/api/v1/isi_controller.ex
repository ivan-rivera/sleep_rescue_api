defmodule SleepRescueWeb.Api.V1.IsiController do
  @moduledoc """
  Controllers for interacting with ISI results
  """

  use SleepRescueWeb, :controller
  alias SleepRescue.Users.Isi
  import SleepRescueWeb.Helpers, only: [json_error: 3]

  @doc """
  List user ISIs
  """
  @spec show(Conn.t(), map()) :: Conn.t()
  def show(conn, _attrs) do
    case Isi.list_isis(conn.assigns.current_user) do
      {:ok, results} -> json(conn, %{isis: results})
      {:error, _} -> json_error(conn, 500, "unable to process request")
    end
  end

  @doc """
  Create or update an ISI result
  """
  @spec update(Conn.t(), map()) :: Conn.t()
  def update(conn, attrs) do
    case Isi.create_or_update_isi(conn.assigns.current_user, attrs) do
      {:ok, _} -> json(conn, %{message: "success"})
      _ -> json_error(conn, 500, "unable to process request")
    end
  end

  @doc """
  Delete an ISI result
  """
  @spec delete(Conn.t(), map()) :: Conn.t()
  def delete(conn, %{"id" => id}) do
    case Isi.delete_isi(conn.assigns.current_user, id) do
      {:ok, _} -> json(conn, %{message: "success"})
      {:error, _} -> json_error(conn, 500, "unable to process request")
    end
  end

end
