defmodule SleepRescueWeb.Api.V1.ThoughtControllerTest do

  use ExUnit.Case, async: true
  use SleepRescueWeb.ConnCase
  alias SleepRescue.Users.{Thought, User}
  alias SleepRescue.Repo
  alias SleepRescue.Test.Support.Defaults

  @now DateTime.utc_now |> DateTime.truncate(:second)
  @email "user456@mail.com"
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
    test "user with no thoughts", %{conn: conn, token: token} do
      conn = conn
             |> Plug.Conn.put_req_header("authorization", token)
             |> get(Routes.api_v1_thought_path(conn, :show))
      assert json = json_response(conn, 200)
      assert json["thoughts"] == []
    end
    test "user with thoughts", %{user: user, conn: conn, token: token} do
      Thought.create_thought(user, Defaults.get_valid_thought)
      conn = conn
             |> Plug.Conn.put_req_header("authorization", token)
             |> get(Routes.api_v1_thought_path(conn, :show))
      assert json = json_response(conn, 200)
      assert length(json["thoughts"]) > 0
    end
  end

  describe "create/2" do
    test "create a valid thought", %{user: user, conn: conn, token: token} do
      conn
      |> Plug.Conn.put_req_header("authorization", token)
      |> post(Routes.api_v1_thought_path(conn, :create, Defaults.get_valid_thought))
      assert {:ok, list_of_goals} = Thought.list_thoughts(user)
      assert length(list_of_goals) > 0
    end
  end

  describe "delete/2" do
    test "delete a thought", %{user: user, conn: conn, token: token} do
      {:ok, t} = Thought.create_thought(user, Defaults.get_valid_thought)
      conn
      |> Plug.Conn.put_req_header("authorization", token)
      |> delete(Routes.api_v1_thought_path(conn, :delete), %{"id" => t.id})
      assert {:ok, []} = Thought.list_thoughts(user)
    end
  end

end
