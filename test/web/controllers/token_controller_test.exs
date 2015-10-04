# defmodule Entice.Web.TokenControllerTest do
#   use Entice.Web.ConnCase

#   setup context do
#     result = %{}
#     result = case context.id do
#       0 -> Map.put(result, :params, %{})
#       _ -> Map.put(result, :params, %{})
#     end
#     {:ok, result}
#   end

#   @tag id: 0
#   test "entity_token write case here", context do
#     {:ok, result} = fetch_route(:get, "/api/token/entity", context)

#     assert result["status"] == "ok", "entity_token should have succeeded but didn't."
#     assert result["message"] ==  "Transferring...", "entity_token returned unexpected value for key: message."
#     assert result["client_id"] ==  id, "entity_token returned unexpected value for key: client_id."
#     assert result["entity_id"] ==  eid, "entity_token returned unexpected value for key: entity_id."
#     assert result["entity_token"] ==  token, "entity_token returned unexpected value for key: entity_token."
#     assert result["map"] ==  map_mod.underscore_name, "entity_token returned unexpected value for key: map."
#     assert result["is_outpost"] ==  map_mod.is_outpost?, "entity_token returned unexpected value for key: is_outpost."
#   end
# end
