defmodule SleepRescueWeb.Api.V1.NightControllerTest do

  use SleepRescueWeb.ConnCase
  alias SleepRescue.Users.User
  alias SleepRescue.Repo

  @now ~U[2021-05-10 00:00:00Z]
  @email "tester1@example.com"
  @password "secret1234"
  @login %{"user" => %{"email" => @email, "password" => @password}}
  @valid_input %{
    "date" => "2021-05-01",
    "night" => %{
      "slept" => true,
      "sleep_attempt_timestamp" => 1619915400,
      "final_awakening_timestamp" => 1619940600,
      "up_timestamp" => 1619941500,
      "falling_asleep_duration" => 15,
      "night_awakenings_duration" => 60,
      "rating" => 6
    }
  }

  setup %{conn: conn} do
    user = %User{}
    |> User.changeset(%{
      email: @email,
      password: @password,
      password_confirmation: @password
    })
    |> Ecto.Changeset.change(%{email_confirmed_at: @now})
    |> Repo.insert!()
    conn_confirmed = post(conn, Routes.api_v1_session_path(conn, :create, @login))
    %{user: user, token: conn_confirmed.private[:api_access_token]}
  end

  describe "update/2" do

    test "create a new entry with valid parameters", %{conn: conn, token: token} do
      conn = conn
             |> Plug.Conn.put_req_header("authorization", token)
             |> patch(Routes.api_v1_night_path(conn, :update, @valid_input))
    assert json = json_response(conn, 200)
    assert json["message"] == "success"
    end

    test "create a new entry with invalid parameters", %{conn: conn, token: token} do
      bad_params = %{@valid_input | "night" => %{@valid_input["night"] | "rating" => -10}}
      conn = conn
             |> Plug.Conn.put_req_header("authorization", token)
             |> patch(Routes.api_v1_night_path(conn, :update, bad_params))
      assert json = json_response(conn, 400)
      assert json["error"]["message"] == "input error"
      assert json["error"]["errors"] == ["rating: is invalid"]
    end

    test "update existing entry with valid parameters", %{conn: conn, token: token} do
      conn
       |> Plug.Conn.put_req_header("authorization", token)
       |> patch(Routes.api_v1_night_path(conn, :update, @valid_input))
      conn
       |> Plug.Conn.put_req_header("authorization", token)
       |> patch(Routes.api_v1_night_path(conn, :update, %{
        "date" => "2021-05-01",
        "night" => %{"rating" => 10}
      }))
      conn = conn
              |> Plug.Conn.put_req_header("authorization", token)
              |> get(Routes.api_v1_night_path(conn, :show, 30))
      assert json = json_response(conn, 200)
      [%{"rating" => rating}] = json["data"]
      assert rating == 10
    end

    test "update existing entry with invalid parameters", %{conn: conn, token: token} do
      conn
      |> Plug.Conn.put_req_header("authorization", token)
      |> patch(Routes.api_v1_night_path(conn, :update, @valid_input))
      conn = conn
              |> Plug.Conn.put_req_header("authorization", token)
              |> patch(Routes.api_v1_night_path(conn, :update, %{
                "date" => "2021-05-01",
                "night" => %{"falling_asleep_duration" => 10000}
              }))
      assert json = json_response(conn, 400)
      assert json["error"]["message"] == "input error"
      assert json["error"]["errors"] == ["nights_table: must have slept zero or more minutes"]
    end

  end

  describe "show/2" do

    setup %{conn: conn, token: token} do
      conn
      |> Plug.Conn.put_req_header("authorization", token)
      |> patch(Routes.api_v1_night_path(conn, :update, @valid_input))
      %{}
    end

    test "with results, but outside history range", %{conn: conn, token: token} do
      conn = conn
             |> Plug.Conn.put_req_header("authorization", token)
             |> get(Routes.api_v1_night_path(conn, :show, 1))
      assert json = json_response(conn, 200)
      assert json["data"] == []
    end

    test "with results", %{conn: conn, token: token} do
     conn = conn
            |> Plug.Conn.put_req_header("authorization", token)
            |> get(Routes.api_v1_night_path(conn, :show, 30))
      assert json = json_response(conn, 200)
      [%{"rating" => rating}] = json["data"]
      assert rating == 6
    end

  end
end
