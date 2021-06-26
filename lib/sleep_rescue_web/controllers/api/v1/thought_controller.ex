defmodule SleepRescueWeb.Api.V1.ThoughtController do
  @moduledoc """
  Controller for user thoughts and counter thoughts
  """

  use SleepRescueWeb, :controller
  alias SleepRescue.Users.Thought
  import SleepRescueWeb.Helpers, only: [json_error: 3]
  require Logger

  @doc """
  List user thoughts and counter thoughts
  """
  @spec show(Conn.t(), map()) :: Conn.t()
  def show(conn, _attrs) do
    case Thought.list_thoughts(conn.assigns.current_user) do
      {:ok, results} -> json(conn, %{thoughts: results})
      {:error, _} -> json_error(conn, 500, "unable to process request")
    end
  end

  @doc """
  Create a thought + counter-thought pair
  """
  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, %{"negative_thought" => _, "counter_thought" => _} = thought) do
    case Thought.create_thought(conn.assigns.current_user, thought) do
      {:ok, _} -> json(conn, %{message: "success"})
      {:error, err} ->
        Logger.error("Failed to create a thought: #{inspect(err)}")
        json_error(conn, 500, "unable to process request")
    end
  end

  @doc """
  Delete a thought + counter-thought pair
  """
  @spec delete(Conn.t(), map()) :: Conn.t()
  def delete(conn, %{"id" => id}) do
    case Thought.delete_thought(conn.assigns.current_user, id) do
      {:ok, _} -> json(conn, %{message: "success"})
      {:error, _} -> json_error(conn, 500, "unable to process request")
    end
  end

end
