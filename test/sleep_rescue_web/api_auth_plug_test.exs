defmodule SleepRescueWeb.ApiAuthPlugTest do

  use ExUnit.Case, async: false
  use SleepRescueWeb.ConnCase
  doctest SleepRescueWeb.ApiAuthPlug

  alias SleepRescueWeb.{ApiAuthPlug, Endpoint}
  alias SleepRescue.{Repo, Users.User}

  @pow_config [otp_app: :sleep_rescue]

  setup %{conn: conn} do
    conn = %{conn | secret_key_base: Endpoint.config(:secret_key_base)}
    user = Repo.insert!(%User{id: 10000, email: "testing@example.com"})
    SleepRescue.Test.Support.Setup.init()
    {:ok, conn: conn, user: user}
  end

  test "can create, fetch, renew, and delete session", %{conn: conn, user: user} do
    assert {_no_auth_conn, nil} = ApiAuthPlug.fetch(conn, @pow_config)

    assert {%{private: %{
                 api_access_token: access_token,
                 api_renewal_token: renewal_token
               }}, ^user} = ApiAuthPlug.create(conn, user, @pow_config)

    :timer.sleep(50)

    assert {_conn, ^user} = ApiAuthPlug.fetch(with_auth_header(conn, access_token), @pow_config)
    assert {%{private: %{
             api_access_token: renewed_access_token,
             api_renewal_token: renewed_renewal_token
           }}, ^user} = ApiAuthPlug.renew(with_auth_header(conn, renewal_token), @pow_config)

    :timer.sleep(50)

    assert {_conn, nil} = ApiAuthPlug.fetch(with_auth_header(conn, access_token), @pow_config)
    assert {_conn, nil} = ApiAuthPlug.renew(with_auth_header(conn, renewal_token), @pow_config)
    assert {_conn, ^user} = ApiAuthPlug.fetch(with_auth_header(conn, renewed_access_token), @pow_config)

    ApiAuthPlug.delete(with_auth_header(conn, renewed_access_token), @pow_config)
    :timer.sleep(50)

    assert {_conn, nil} = ApiAuthPlug.fetch(with_auth_header(conn, renewed_access_token), @pow_config)
    assert {_conn, nil} = ApiAuthPlug.renew(with_auth_header(conn, renewed_renewal_token), @pow_config)
  end

  defp with_auth_header(conn, token), do: Plug.Conn.put_req_header(conn, "authorization", token)

end
