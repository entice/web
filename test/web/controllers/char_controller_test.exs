defmodule Entice.Web.CharControllerTest do
  use Entice.Web.ConnCase

  setup _context do
    {:ok, %{email: "root@entice.ps", password: "root"}}
  end


  test "create character if it has a unique name w/o appearance", context do
    conn = conn(:post, "/api/char", %{name: "Im sooooooo unique 1"}) |> with_session(context)

    conn = Entice.Web.Router.call(conn, @opts)

    {:ok, result} = Poison.decode(conn.resp_body)
    assert result["status"] == "ok"
    assert %{"name" => "Im sooooooo unique 1"} = result["character"]
  end


  test "create character if it has a unique name w/ some appearance", context do
    conn = conn(:post, "/api/char", %{
      name: "Im sooooooo unique 2",
      skin_color: 13,
      hair_color: 13}) |> with_session(context)

    conn = Entice.Web.Router.call(conn, @opts)

    {:ok, result} = Poison.decode(conn.resp_body)
    assert result["status"] == "ok"
    assert %{"name" => "Im sooooooo unique 2", "skin_color" => 13, "hair_color" => 13} = result["character"]
  end


  test "don't create character if it has a non-unique name", context do
    conn = conn(:post, "/api/char", %{name: "Im not so unique, meh"}) |> with_session(context)

    conn = Entice.Web.Router.call(conn, @opts)

    {:ok, result} = Poison.decode(conn.resp_body)
    assert result["status"] == "ok"

    conn = conn(:post, "/api/char", %{name: "Im not so unique, meh"}) |> with_session(context)

    conn = Entice.Web.Router.call(conn, @opts)

    {:ok, result} = Poison.decode(conn.resp_body)
    assert result["status"] == "error"
  end
end
