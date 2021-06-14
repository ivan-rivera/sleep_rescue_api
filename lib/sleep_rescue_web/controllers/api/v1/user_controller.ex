defmodule SleepRescueWeb.Api.V1.UserController do
  @moduledoc """
  Controllers for registering new users
  """

  use SleepRescueWeb, :controller
  alias SleepRescue.Repo
  alias SleepRescue.Users.{User, Night}
  alias Ecto.Changeset
  alias Plug.Conn
  alias SleepRescueWeb.ErrorHelpers
  import SleepRescueWeb.Helpers, only: [json_error: 3, json_error: 4, send_confirmation_email: 2]

  @spec show(Conn.t(), map()) :: Conn.t()
  def show(conn, _params) do
    json(conn, %{
      user: Pow.Plug.current_user(conn),
      nights: Night.list_nights(conn.assigns.current_user, 9999) |> length
    })
  end


  @doc """
  Register a new user
  """
  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, %{"user" => user_params}) do
    conn
    |> Pow.Plug.create_user(user_params)
    |> case do
         {:ok, user, conn} ->
          send_confirmation_email(conn, user)
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
           json_error(conn, 500, message, errors)
       end
  end

  def create(conn, _params), do: json_error(conn, 400, "malformed request")


  @doc """
  Delete user
  This action is password protected
  """
  @spec delete(Conn.t(), map()) :: Conn.t()
  def delete(conn, %{"current_password" => password}) do
    with  user when not is_nil(user) <- conn.assigns.current_user,
          true <- User.verify_password(user, password),
          {:ok, _u} <- User.delete(user.id) do
            json(conn, %{message: "success"})
    else
          nil -> json_error(conn, 404, "user not found")
          false -> json_error(conn, 401, "wrong password")
          _ -> json_error(conn, 500, "server error")
    end
  end

  def delete(conn, _params), do: json_error(conn, 400, "no password provided")


  @doc """
  Update users settings
  This action can update users email and or password
  """
  @spec update(Conn.t(), map()) :: Conn.t()
  def update(conn, params = %{"email" => email}) do
    case Repo.get_by(User, email: email) do
      nil -> update_user(conn, params)
      _ -> json_error(conn, 400, "This email has already been taken")
    end
  end

  def update(conn, params), do: update_user(conn, params)


  @doc """
  Allow users to cancel their email change request.
  This may help in situations where the user accidentally types the wrong email
  address that they don't have access to and they get locked out of their account
  """
  @spec cancel_email_change(Conn.t(), map()) :: Conn.t()
  def cancel_email_change(conn, _params) do
    if is_nil(conn.assigns.current_user.email_confirmed_at) do
      json_error(conn, 400, "Cannot cancel, the primary email has not been confirmed")
    else
      case conn.assigns.current_user
           |> Ecto.Changeset.change(%{unconfirmed_email: nil})
           |> Repo.update() do
        {:ok, _user} -> json(conn, %{message: "success"})
        {:error, _cs} ->
          json_error(conn, 500, "Failed undo email change request")
      end
    end
  end


  @spec update_user(Conn.t(), map()) :: Conn.t()
  defp update_user(conn, params) do
    case conn.assigns.current_user
         |> User.changeset(params)
         |> Repo.update() do
      {:ok, user} ->
        unless is_nil(user.unconfirmed_email), do: send_confirmation_email(conn, user)
        json(conn, %{message: "success"})
      {:error, user} ->
        case Keyword.has_key?(user.errors, :current_password) do
          true -> json_error(conn, 400, "Wrong password")
          false -> json_error(conn, 400, "Server error")
        end
    end
  end

end
