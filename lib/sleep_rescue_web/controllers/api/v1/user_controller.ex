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
  alias SleepRescue.Mail.Mailer
  alias SleepRescue.Email
  import PowEmailConfirmation.Plug, only: [load_user_by_token: 2]
  import PowEmailConfirmation.Ecto.Context, only: [confirm_email: 3]

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
           Helpers.json_error(conn, 500, message, errors)
       end
  end

  def create(conn, _params), do: Helpers.json_error(conn, 400, "malformed request")


  @doc """
  Given a confirmation token, mark that that the user has confirmed their email
  """
  @spec confirm_email(Conn.t(), map()) :: Conn.t()
  def confirm_email(conn, %{"token" => token}) do
    with  {:ok, conn}  <- load_user_by_token(conn, token),
          {:ok, _user} <- confirm_email(conn.assigns.confirm_email_user, %{}, otp_app: :sleep_rescue) do
      json(conn, %{success: %{message: "Email confirmed"}})
    else
      _ -> Helpers.json_error(conn, 401, "Invalid confirmation code")
    end
  end


  @doc """
  Allow users to request another confirmation email in case they didnt receive the first one
  """
  @spec resend_email_confirmation(Conn.t(), map()) :: Conn.t()
  def resend_email_confirmation(conn, _params) do
    send_confirmation_email(conn, conn.assigns.current_user)
  end


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
  def update(conn, params) do
    case conn.assigns.current_user
         |> User.changeset(params)
         |> Repo.update() do
      {:ok, user} ->
        unless is_nil(user.unconfirmed_email), do: send_confirmation_email(conn, user)
        json(conn, %{data: %{message: "success"}})
      {:error, u} ->
        IO.inspect(u)
        Helpers.json_error(conn, 400, "failed to update user")
    end
  end


  @spec send_confirmation_email(Conn.t(), map()) :: Conn.t()
  defp send_confirmation_email(conn, user) do
    token = PowEmailConfirmation.Plug.sign_confirmation_token(conn, user)
    case (user.unconfirmed_email || user.email)
       |> Email.confirmation_email(token)
       |> Mailer.deliver_later() do
      {:ok, _} -> json(conn, %{data: %{message: "message sent"}})
      _ -> Helpers.json_error(conn, 500, "unable to send the message")
    end
  end

end
