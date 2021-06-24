defmodule SleepRescueWeb.Api.V1.GoalControllerTest do

  use SleepRescueWeb.ConnCase
  alias SleepRescue.Users.{Isi, User}
  alias SleepRescue.Repo
  alias SleepRescue.Test.Support.Defaults

  @now DateTime.utc_now |> DateTime.truncate(:second)
  @email "user@mail.com"
  @password "secret123"
  @login %{"user" => %{"email" => @email, "password" => @password}}
  @user %{
    email: @email,
    password: @password,
    password_confirmation: @password
  }

  setup %{conn: conn} do
    user = %User{}
           |> User.changeset(@user)
           |> Ecto.Changeset.change(%{email_confirmed_at: @now})
           |> Repo.insert!()
    conn_confirmed = post(conn, Routes.api_v1_session_path(conn, :create, @login))
    %{user: user, token: conn_confirmed.private[:api_access_token]}
  end

  describe "show/2" do
    test "records for a user who has records", %{conn: conn, token: token} do
      conn = conn
             |> Plug.Conn.put_req_header("authorization", token)
             |> get(Routes.api_v1_isi_path(conn, :show))
      assert json = json_response(conn, 200)
      assert json["isis"] == []
    end
    test "records for a user with no records", %{user: user, conn: conn, token: token} do
      Isi.create_or_update_isi(user, Defaults.get_valid_isi)
      conn = conn
             |> Plug.Conn.put_req_header("authorization", token)
             |> get(Routes.api_v1_isi_path(conn, :show))
      assert json = json_response(conn, 200)
      assert length(json["isis"]) == 1
    end
  end

  describe "update/2" do
    test "a new ISI record",  %{user: user, conn: conn, token: token} do
      conn
      |> Plug.Conn.put_req_header("authorization", token)
      |> patch(Routes.api_v1_isi_path(conn, :update, Defaults.get_valid_isi))
      assert {:ok, list_of_isis} = Isi.list_isis(user)
      assert length(list_of_isis) == 1
    end
    test "update an ISI record", %{user: user, conn: conn, token: token} do
      Isi.create_or_update_isi(user, Defaults.get_valid_isi)
      conn
      |> Plug.Conn.put_req_header("authorization", token)
      |> patch(Routes.api_v1_isi_path(conn, :update, Defaults.get_valid_isi))
      assert {:ok, list_of_isis} = Isi.list_isis(user)
      assert length(list_of_isis) == 1
    end
  end

  describe "delete/2" do
    test "delete an ISI record", %{user: user, conn: conn, token: token} do
      {:ok, i} = Isi.create_or_update_isi(user, Defaults.get_valid_isi)
      conn
      |> Plug.Conn.put_req_header("authorization", token)
      |> delete(Routes.api_v1_isi_path(conn, :delete), %{"id" => i.id})
      assert {:ok, []} = Isi.list_isis(user)
    end
  end

end
