# defmodule Entice.Web.DocuControllerTest do
#   use Entice.Web.ConnCase

#   setup context do
#     result = %{}
#     result = case context.id do
#       0 -> Map.put(result, :params, %{})
#       1 -> Map.put(result, :params, %{})
#       2 -> Map.put(result, :params, %{})
#       3 -> Map.put(result, :params, %{})
#       _ -> Map.put(result, :params, %{})
#     end
#     {:ok, result}
#   end

#   @tag id: 0
#   test "maps write case here", context do
#     {:ok, result} = fetch_route(:get, "/api/maps", context)

#     assert result["status"] == "ok", "maps should have succeeded but didn't."
#     assert result["message"] ==  "All maps...", "maps returned unexpected value for key: message."
#     assert result["maps"] ==  maps, "maps returned unexpected value for key: maps."
#   end

#   @tag id: 1
#   test "skills write case here", context do
#     {:ok, result} = fetch_route(:get, "/api/skills", context)

#     assert result["status"] == "error", "skills should have failed but didn't."
#     assert result["message"] ==  m, "skills returned unexpected value for key: message."
#   end

#   @tag id: 2
#   test "skills write case here", context do
#     {:ok, result} = fetch_route(:get, "/api/skills/:id", context)

#     assert result["status"] == "ok", "skills should have succeeded but didn't."
#     assert result["message"] ==  "Requested skill...", "skills returned unexpected value for key: message."
#     assert result["skill"] ==  %{            id, "skills returned unexpected value for key: skill."
#     assert result["name"] ==  s.underscore_name, "skills returned unexpected value for key: name."
#     assert result["description"] ==  s.description}, "skills returned unexpected value for key: description."
#   end

#   @tag id: 3
#   test "skills write case here", context do
#     {:ok, result} = fetch_route(:get, "/api/skills", context)

#     assert result["status"] == "ok", "skills should have succeeded but didn't."
#     assert result["message"] ==  "All skills...", "skills returned unexpected value for key: message."
#     assert result["skill"] ==  sk, "skills returned unexpected value for key: skill."
#   end
# end
