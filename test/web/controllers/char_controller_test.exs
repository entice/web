defmodule Entice.Web.CharControllerTest do
  use Entice.Web.ConnCase

  setup context do
    result = %{email: "root@entice.ps", password: "root" }
    result = case context.id do
      1 -> Map.put(result, :params, %{char_name: "Im sooooooo unique 1"})
      2 -> Map.put(result, :params, %{char_name: "Im sooooooo unique 2", skin_color: 13, hair_color: 13})
      3 -> Map.put(result, :params, %{char_name: "Im not so unique, meh"})
    end
    {:ok, result}
  end


  @tag id: 1
  test "create character if it has a unique name w/o appearance", context do
    {:ok, result} = fetch_route(:post, "/api/char", context)

    assert result["status"] == "ok"
    assert %{"name" => "Im sooooooo unique 1"} = result["character"]
  end

  @tag id: 2
  test "create character if it has a unique name w/ some appearance", context do
    {:ok, result} = fetch_route(:post, "/api/char", context)

    assert result["status"] == "ok"
    assert %{"name" => "Im sooooooo unique 2", "skin_color" => 13, "hair_color" => 13} = result["character"]
  end

  @tag id: 3
  test "don't create character if it has a non-unique name", context do
    {:ok, result} = fetch_route(:post, "/api/char", context)

    assert result["status"] == "ok"

    {:ok, result} = fetch_route(:post, "/api/char", context)

    assert result["status"] == "error"
  end
end
