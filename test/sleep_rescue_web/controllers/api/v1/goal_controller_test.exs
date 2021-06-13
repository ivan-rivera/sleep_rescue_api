defmodule SleepRescueWeb.Api.V1.GoalControllerTest do

  use SleepRescueWeb.ConnCase
  alias SleepRescue.Users.{Goal, User}
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

    test "user with no goals", %{conn: conn, token: token} do
      conn = conn
             |> Plug.Conn.put_req_header("authorization", token)
             |> get(Routes.api_v1_goal_path(conn, :show))
      assert json = json_response(conn, 200)
      assert json["goals"] == []
    end

    test "user with a goal", %{user: user, conn: conn, token: token} do
      Goal.create_goal(user, Defaults.get_valid_goal)
      conn = conn
             |> Plug.Conn.put_req_header("authorization", token)
             |> get(Routes.api_v1_goal_path(conn, :show))
      assert json = json_response(conn, 200)
      assert length(json["goals"]) == 1
    end

  end

  test "create/2", %{user: user, conn: conn, token: token} do
    conn
    |> Plug.Conn.put_req_header("authorization", token)
    |> post(Routes.api_v1_goal_path(conn, :create, Defaults.get_valid_goal))
    assert {:ok, list_of_goals} = Goal.list_goals(user, Defaults.get_today)
    assert length(list_of_goals) == 1
  end

  test "delete/2", %{user: user, conn: conn, token: token} do
  {:ok, g} = Goal.create_goal(user, Defaults.get_valid_goal)
    conn
    |> Plug.Conn.put_req_header("authorization", token)
    |> delete(Routes.api_v1_goal_path(conn, :delete), %{"id" => g.id})
    assert {:ok, []} = Goal.list_goals(user, Defaults.get_today)
  end

end
