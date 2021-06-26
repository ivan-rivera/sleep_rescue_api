defmodule SleepRescueWeb.Api.V1.GoalController do
  @moduledoc """
  Controllers for interacting with goals
  """

  use SleepRescueWeb, :controller
  alias SleepRescue.Users.Goal
  import SleepRescueWeb.Helpers, only: [json_error: 3]
  require Logger

  @doc """
  List user goals
  """
  @spec show(Conn.t(), map()) :: Conn.t()
  def show(conn, _attrs) do
    case Goal.list_goals(conn.assigns.current_user) do
      {:ok, results} -> json(conn, %{goals: results})
      {:error, _} ->
        json_error(conn, 500, "unable to process request")
    end
  end

  @doc """
  Create a new goal
  """
  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, %{"metric" => _, "duration" => _, "threshold" => _} = attrs) do
    case Goal.create_goal(conn.assigns.current_user, attrs) do
      {:ok, _} -> json(conn, %{message: "success"})
      _ ->
        Logger.metadata(user_id: conn.assigns.current_user.id)
        Logger.error("Failed to create a goal with settings: #{inspect(attrs)}")
        json_error(conn, 500, "unable to process request")
    end
  end

  @doc """
  Delete a goal
  """
  @spec delete(Conn.t(), map()) :: Conn.t()
  def delete(conn, %{"id" => id}) do
    case Goal.delete(id, conn.assigns.current_user) do
      {:ok, _} -> json(conn, %{message: "success"})
      {:error, _} ->
        Logger.error("Unable to delete goal ID #{id} for user #{conn.assigns.current_user.id}")
        json_error(conn, 500, "unable to process request")
    end
  end

end
