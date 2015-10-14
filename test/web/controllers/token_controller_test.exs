defmodule Entice.Web.TokenControllerTest do
  use Entice.Web.ConnCase

  setup do
    result = %{email: "root@entice.ps", password: "root" }
    result = Map.put(result, :params, %{client_version: "TestVersion", map: "heroes_ascent", char_name: "Root Root A"})
    {:ok, result}
  end

  @tag id: 0
  test "entity_token success", context do
    {:ok, result} = fetch_route(:get, "/api/token/entity", context)

    assert result["status"] == "ok", "entity_token should have succeeded but didn't."
    assert result["message"] ==  "Transferring...", "entity_token returned unexpected value for key: message."
    assert result["map"] ==  "heroes_ascent", "entity_token returned unexpected value for key: map."
    assert result["is_outpost"] ==  true, "entity_token returned unexpected value for key: is_outpost."
  end
end
