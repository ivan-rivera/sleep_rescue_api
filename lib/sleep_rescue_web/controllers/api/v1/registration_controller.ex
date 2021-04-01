defmodule SleepRescueWeb.Api.V1.RegistrationController do
  @moduledoc """
  Controllers for registering new users
  """

  use SleepRescueWeb, :controller
  # TODO: password resets and email changes
  alias Ecto.Changeset
  alias Plug.Conn
  alias SleepRescueWeb.ErrorHelpers

  @doc """
  Create a new user
  """
  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, %{"user" => user_params}) do
    IO.inspect user_params
    conn
    |> Pow.Plug.create_user(user_params)
    |> case do
         {:ok, _user, conn} ->
           json(conn, %{
             data: %{
               access_token: conn.private.api_access_token,
               renewal_token: conn.private.api_renewal_token
             }
           })

         {:error, changeset, conn} ->
           errors = Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)
           conn
           |> put_status(500)
           |> json(%{error: %{status: 500, message: "Could not create user", errors: errors}})
       end
  end

end
