defmodule SleepRescueWeb.Api.V1.UserControllerTest do

  use ExUnit.Case, async: true
  use SleepRescueWeb.ConnCase
  alias SleepRescue.Users.User
  alias SleepRescue.Repo

  @now DateTime.utc_now |> DateTime.truncate(:second)
  @password "secret1234"
  @confirmed_email "tester1@example.com"
  @unconfirmed_email "tester2@example.com"
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

    authed_conn_confirmed = post(conn, Routes.api_v1_session_path(conn, :create, @confirmed_valid_login))
    authed_conn_unconfirmed = post(conn, Routes.api_v1_session_path(conn, :create, @unconfirmed_valid_login))
    SleepRescue.Test.Support.Setup.init()
    {
      :ok,
      confirmed_user: confirmed_user,
      unconfirmed_user: unconfirmed_user,
      confirmed_access_token: authed_conn_confirmed.private[:api_access_token],
      unconfirmed_access_token: authed_conn_unconfirmed.private[:api_access_token]
    }
  end

  describe "create/2" do

    @valid_params %{"user" => %{
      "email" => "test@example.com",
      "password" => @password,
      "password_confirmation" => @password
    }}

    @invalid_params %{"user" => %{
      "email" => "invalid",
      "password" => @password,
      "password_confirmation" => ""
    }}

    test "with valid params", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :create, @valid_params))
      assert json = json_response(conn, 200)
      assert json["data"]["access_token"]
      assert json["data"]["renewal_token"]
    end

    test "with invalid params", %{conn: conn} do
      conn = post(conn, Routes.api_v1_user_path(conn, :create, @invalid_params))
      assert json = json_response(conn, 500)
      assert json["error"]["message"] == "Email problems: has invalid format"
    end
  end

  describe "show/2" do
    test "authenticated", %{conn: conn, confirmed_access_token: token} do
      conn = conn
        |> Plug.Conn.put_req_header("authorization", token)
        |> get(Routes.api_v1_user_path(conn, :show))
      assert json = json_response(conn, 200)
      assert json["user"]["email"] == @confirmed_email
    end
  end

  describe "delete/2" do
    test "delete unconfirmed user", %{conn: conn, unconfirmed_access_token: token} do
      conn =
        conn
        |> Plug.Conn.put_req_header("authorization", token)
        |> delete(Routes.api_v1_user_path(conn, :delete), %{"current_password" => @password})
      assert json_response(conn, 200)
    end

    test "delete confirmed user", %{conn: conn, confirmed_access_token: token} do
      conn = conn
        |> Plug.Conn.put_req_header("authorization", token)
        |> delete(Routes.api_v1_user_path(conn, :delete), %{"current_password" => @password})
      assert json = json_response(conn, 200)
      assert json["message"] == "success"
    end
  end

  describe "update/2" do

    test "update email", %{conn: conn, confirmed_access_token: token} do
      confirmed_user_id = Repo.get_by(User, email: @confirmed_email).id
      conn = conn
       |> Plug.Conn.put_req_header("authorization", token)
       |> patch(Routes.api_v1_user_path(conn, :update, %{
        "email" => "tester2@mail.com",
        "current_password" => @password
      }))
      assert json = json_response(conn, 200)
      assert json["message"] == "success"
      assert Repo.get_by(User, id: confirmed_user_id).unconfirmed_email == "tester2@mail.com"
    end

    test "update password", %{conn: conn, confirmed_access_token: token} do
      assert conn
       |> Plug.Conn.put_req_header("authorization", token)
       |> patch(Routes.api_v1_user_path(conn, :update, %{
          "current_password" => @password,
          "password" => "new_password123",
          "password_confirmation" => "new_password123"
        }))
       |> post(Routes.api_v1_session_path(conn, :create, %{
          "user" => %{
            "email" => @confirmed_email,
            "password" => "new_password123"
          }
       }))
       |> json_response(200)
    end

  end

end
