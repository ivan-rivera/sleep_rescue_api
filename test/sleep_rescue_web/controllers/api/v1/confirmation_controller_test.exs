defmodule SleepRescueWeb.Api.V1.ConfirmationControllerTest do

  use ExUnit.Case, async: false
  use SleepRescueWeb.ConnCase
  alias SleepRescue.Users.User
  alias SleepRescue.Repo

  @now DateTime.utc_now |> DateTime.truncate(:second)
  @password "secret1234"
  @confirmed_email "tester12@example.com"
  @unconfirmed_email "tester23@example.com"
  @confirmed_valid_login %{"user" => %{"email" => @confirmed_email, "password" => @password}}
  @unconfirmed_valid_login %{"user" => %{"email" => @unconfirmed_email, "password" => @password}}

  setup %{conn: conn} do
    unconfirmed_user = %User{}
      |> User.changeset(%{
        email: @unconfirmed_email,
        password: @password,
        password_confirmation: @password
      })
      |> Repo.insert!()

    confirmed_user = %User{}
      |> User.changeset(%{
        email: @confirmed_email,
        password: @password,
        password_confirmation: @password
      })
        |> Ecto.Changeset.change(%{email_confirmed_at: @now})
        |> Repo.insert!()

    :timer.sleep(50)
    authed_conn_confirmed = post(conn, Routes.api_v1_session_path(conn, :create, @confirmed_valid_login))
    authed_conn_unconfirmed = post(conn, Routes.api_v1_session_path(conn, :create, @unconfirmed_valid_login))
    {
      :ok,
      confirmed_user: confirmed_user,
      unconfirmed_user: unconfirmed_user,
      confirmed_access_token: authed_conn_confirmed.private[:api_access_token],
      unconfirmed_access_token: authed_conn_unconfirmed.private[:api_access_token]
    }
  end

  describe "get_confirmation_status/2" do
    test "confirmed user", %{conn: conn, confirmed_access_token: token} do
      json = conn
             |> Plug.Conn.put_req_header("authorization", token)
             |> get(Routes.api_v1_confirmation_path(conn, :get_confirmation_status))
             |> json_response(200)
      assert json["email_is_confirmed"]
    end

    test "unconfirmed user", %{conn: conn, unconfirmed_access_token: token} do
      json = conn
             |> Plug.Conn.put_req_header("authorization", token)
             |> get(Routes.api_v1_confirmation_path(conn, :get_confirmation_status))
             |> json_response(200)
      assert not json["email_is_confirmed"]
    end

  end

end
