defmodule Entice.Web.CharControllerTest do
  use Entice.Web.ConnCase


  setup _context do
    {:ok, %{email: "root@entice.ps", password: "root"}}
  end


  test "create character if it has a unique name w/o appearance", context do
    conn = conn(:post, "/api/char", %{name: "Im sooooooo unique"}) |> with_session(context)

    conn = Entice.Web.Router.call(conn, @opts)

    {:ok, result} = Poison.decode(conn.resp_body)
    assert result["status"] == "ok"
    assert %{name: "Im sooooooo unique"} = result["char"]
  end

  test "create character if it has a unique name w/ some appearance", context do
    conn = conn(:post, "/api/char", %{
      name: "Im sooooooo unique",
      skin_color: 13,
      hair_color: 13}) |> with_session(context)

    conn = Entice.Web.Router.call(conn, @opts)

    {:ok, result} = Poison.decode(conn.resp_body)
    assert result["status"] == "ok"
    assert %{name: "Im sooooooo unique", skin_color: 13, hair_color: 13} = result["char"]
  end
end
