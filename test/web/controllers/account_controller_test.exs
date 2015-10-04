defmodule Entice.Web.AccountControllerTest do
  use Entice.Web.ConnCase

  setup context do
    #IO.puts "Setting up: #{context[:test]}"
    result = {:ok, %{email: "root@entice.ps", password: "root" }}
    case context[:test] do
      "by_char_name wrong char name" -> Map.put(result, :char_name, "name does not exist")
      "by_char_name existing char name" -> Map.put(result, :char_name, "root@entice.ps 1")
      _ -> result
    end
  end

  test "by_char_name wrong char name", context do
    conn = conn(:get, "/api/account/by_char_name", %{char_name: "esafeawse"})
    |> with_session(context)
    conn = Entice.Web.Router.call(conn, @opts)

    {:ok, result} = Poison.decode(conn.resp_body)
    assert result["status"] == "error", "by_char_name should have failed but didn't."
    assert result["message"] == "Couldn't find character.", "by_char_name did not fail in the expected way."
  end

  test "by_char_name existing char name", context do
    conn = conn(:get, "/api/account/by_char_name", %{char_name: "root@entice.ps 1"})
    |> with_session(context)
    conn = Entice.Web.Router.call(conn, @opts)

    {:ok, result} = Poison.decode(conn.resp_body)
    assert result["status"] == "ok", "by_char_name should have succeeded but didn't."
  end

  test "request_invite email already in use", context do
    conn = conn(:post, "/api/account/request", %{email: "root@entice.ps"})
    |> with_session(context)
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
