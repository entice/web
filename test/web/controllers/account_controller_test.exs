defmodule Entice.Web.AccountControllerTest do
  use ExUnit.Case
  use Entice.Web.ConnCase

  @opts Entice.Web.Router.init([])

  def with_session(conn) do
    session_opts = Plug.Session.init(store: :cookie,
      key: "_app",
      encryption_salt: "abc",
      signing_salt: "abc")

    {:ok, id} = Entice.Web.Client.log_in("root@entice.ps", "root")
    conn
    |> Map.put(:secret_key_base, String.duplicate("abcdefgh", 8))
    |> Plug.Session.call(session_opts)
    |> Plug.Conn.fetch_session()
    |> put_session(:email, "root@entice.ps")
    |> put_session(:client_id, id)
  end

  setup do
    #TODO insert all necessary rows in the db for cleaner tests
    {:ok, %{}}
  end

  test "by_char_name wrong char name" do
    conn = with_session conn(:get, "/api/account/by_char_name", %{char_name: "esafeawse"})
    conn = Entice.Web.Router.call(conn, @opts)

    {:ok, result} = Poison.decode(conn.resp_body)
    assert result["status"] == "error", "by_char_name should have failed but didn't."
    assert result["message"] == "Couldn't find character.", "by_char_name did not fail in the expected way."
  end

  test "by_char_name existing char name" do
    conn = with_session conn(:get, "/api/account/by_char_name", %{char_name: "Test Char"})
    conn = Entice.Web.Router.call(conn, @opts)

    {:ok, result} = Poison.decode(conn.resp_body)
    assert result["status"] == "ok", "by_char_name should have succeeded but didn't."
    assert result["account_id"] == 1, "by_char_name did not return the right account_id."
  end

  test "request_invite email already in use" do
    conn = with_session conn(:post, "/api/account/request", %{email: "root@entice.ps"})
    conn = Entice.Web.Router.call(conn, @opts)

    {:ok, result} = Poison.decode(conn.resp_body)
    assert result["status"] == "error", "request_invite should have failed but didn't."
    assert result["message"] == "This Email address is already in use", "request_invite did not fail in the expected way."
  end

  test "request_invite already invited" do
  end

  test "request_invite correct parameters" do
  end

  test "register no invite" do
  end

  test "register wrong key" do
  end

  test "register correct parameters" do
  end

end
