defmodule SleepRescueWeb.Api.V1.UserController do
  @moduledoc """
  Controllers for registering new users
  """

  use SleepRescueWeb, :controller
  alias SleepRescue.Repo
  alias SleepRescue.Users.User
  alias Ecto.Changeset
  alias Plug.Conn
  alias SleepRescueWeb.ErrorHelpers
  alias SleepRescueWeb.Helpers

  @spec show(Conn.t(), map()) :: Conn.t()
  def show(conn, _params) do
    json(conn, %{user: Pow.Plug.current_user(conn)})
  end


  @doc """
  Register a new user
  """
  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, %{"user" => user_params}) do
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
           message = case errors do
             %{email: [email_error | _other]} -> "Email problems: " <> email_error
             _ -> "server error"
           end
           Helpers.json_error(conn, 500, message, errors)
       end
  end

  def create(conn, _params), do: Helpers.json_error(conn, 400, "malformed request")


  @doc """
  Delete user
  This action is password protected
  """
  @spec delete(Conn.t(), map()) :: Conn.t()
  def delete(conn, %{"current_password" => password}) do
    with  user when not is_nil(user) <- conn.assigns.current_user,
          true <- User.verify_password(user, password),
          {:ok, _u} <- User.delete(user.id) do
            json(conn, %{data: %{message: "success"}})
    else
          nil -> Helpers.json_error(conn, 404, "user not found")
          false -> Helpers.json_error(conn, 401, "wrong password")
          _ -> Helpers.json_error(conn, 500, "server error")
    end
  end

  def delete(conn, _params), do: Helpers.json_error(conn, 400, "no password provided")


  @doc """
  Update users settings
  This action can update users email and or password
  """
  @spec update(Conn.t(), map()) :: Conn.t()
  def update(conn, params = %{
    "current_password" => _,
    "email" => _
  }), do: update_user(conn, params)
  def update(conn, params = %{
    "current_password" => _,
    "password" => _,
    "password_confirmation" => _
  }), do: update_user(conn, params)
  def update(conn, _params), do: Helpers.json_error(conn, 400, "malformed request")


  @spec update_user(Conn.t(), map()) :: Conn.t()
  defp update_user(conn, params) do
    case conn.assigns.current_user
         |> User.changeset(params)
         |> Repo.update() do
      {:ok, _cs} -> json(conn, %{data: %{message: "success"}})
      {:error, _cs} -> Helpers.json_error(conn, 400, "failed to update user")
    end
  end

end
