defmodule SleepRescueWeb.Api.V1.SessionController do
  @moduledoc """
  Controller for handling sessions
  """

  use SleepRescueWeb, :controller

  alias SleepRescueWeb.ApiAuthPlug
  alias Plug.Conn

  @doc """
  Create a new session
  """
  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, %{"user" => user_params}) do
    conn
    |> Pow.Plug.authenticate_user(user_params)
    |> case do
         {:ok, conn} ->
           json(conn, %{
             data: %{
               access_token: conn.private.api_access_token,
               renewal_token: conn.private.api_renewal_token
             }
           })

         {:error, conn} ->
           conn
           |> put_status(401)
           |> json(%{error: %{message: "Invalid email or password"}})
       end
  end

  @doc """
  Renew session
  """
  @spec renew(Conn.t(), map()) :: Conn.t()
  def renew(conn, _params) do
    config = Pow.Plug.fetch_config(conn)

    conn
    |> ApiAuthPlug.renew(config)
    |> case do
         {conn, nil} ->
           conn
           |> put_status(401)
           |> json(%{error: %{message: "Invalid token"}})

         {conn, _user} ->
           json(conn, %{
             data: %{
               access_token: conn.private.api_access_token,
               renewal_token: conn.private.api_renewal_token
             }
           })
       end
  end

  @doc """
  Delete session
  """
  @spec delete(Conn.t(), map()) :: Conn.t()
  def delete(conn, _params) do
    conn
    |> Pow.Plug.delete()
    |> json(%{data: %{}})
  end

end
