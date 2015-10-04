defmodule Entice.Web.CharControllerTest do
  use Entice.Web.ConnCase

  setup context do
    result = %{email: "root@entice.ps", password: "root" }
    result = case context.id do
      0 -> Map.put(result, :params, %{})
      1 -> Map.put(result, :params, %{name: 'New Name', available_skills: '3FF', skillbar: '{0, 0, 0, 0, 0, 0, 0, 0}', profession: 1, campaign: 0, sex: 1, height: 0, skin_color: 3, hair_color: 0, hairstyle: 7, face: 30})
      2 -> Map.put(result, :params, %{name: 'Test Char', available_skills: '3FF', skillbar: '{0, 0, 0, 0, 0, 0, 0, 0}', profession: 1, campaign: 0, sex: 1, height: 0, skin_color: 3, hair_color: 0, hairstyle: 7, face: 30})
      _ -> Map.put(result, :params, %{})
    end
    {:ok, result}
  end

  @tag id: 0
  test "list success", context do
    {:ok, result} = fetch_route(:get, "/api/char", context)

    assert result["status"] == "ok", "list should have succeeded but didn't."
    assert result["message"] ==  "All chars...", "list returned unexpected value for key: message."
    assert hd(result["characters"])["name"] ==  "Test Char", "list returned unexpected value for key: characters."
  end

  # @tag id: 1
  # test "create success", context do
  #   {:ok, result} = fetch_route(:post, "/api/char", context)

  #   assert result["status"] == "ok", "create should have succeeded but didn't."
  #   assert result["message"] ==  "Char created.", "create returned unexpected value for key: message."
  #   assert result["character"] ==  context.char , "create returned unexpected value for key: character."
  # end

  # @tag id: 2
  # test "create name already exists", context do
  #   {:ok, result} = fetch_route(:post, "/api/char", context)

  #   assert result["status"] == "error", "create should have failed but didn't."
  #   assert result["message"] ==  "Could not create char. The name is already in use.", "create returned unexpected value for key: message."
  # end

end
