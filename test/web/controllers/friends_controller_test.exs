# defmodule Entice.Web.FriendsControllerTest do
#   use Entice.Web.ConnCase

#   setup context do
#     result = %{}
#     result = case context.id do
#       0 -> Map.put(result, :params, %{})
#       1 -> Map.put(result, :params, %{})
#       2 -> Map.put(result, :params, %{})
#       3 -> Map.put(result, :params, %{})
#       4 -> Map.put(result, :params, %{})
#       5 -> Map.put(result, :params, %{})
#       6 -> Map.put(result, :params, %{})
#       _ -> Map.put(result, :params, %{})
#     end
#     {:ok, result}
#   end

#   @tag id: 0
#   test "index write case here", context do
#     {:ok, result} = fetch_route(:get, "/api/friend", context)

#     assert result["status"] == "ok", "index should have succeeded but didn't."
#     assert result["message"] ==  "All friends", "index returned unexpected value for key: message."
#     assert result["friends"] ==  friends, "index returned unexpected value for key: friends."
#   end

#   @tag id: 1
#   test "create write case here", context do
#     {:ok, result} = fetch_route(:post, "/api/friend", context)

#     assert result["status"] == "ok", "create should have succeeded but didn't."
#     assert result["message"] ==  "Friend added.", "create returned unexpected value for key: message."
#   end

#   @tag id: 2
#   test "create write case here", context do
#     {:ok, result} = fetch_route(:post, "/api/friend", context)

#     assert result["status"] == "error", "create should have failed but didn't."
#     assert result["message"] ==  "This account does not exist.", "create returned unexpected value for key: message."
#   end

#   @tag id: 3
#   test "create write case here", context do
#     {:ok, result} = fetch_route(:post, "/api/friend", context)

#     assert result["status"] == "error", "create should have failed but didn't."
#     assert result["message"] ==  "Can't add yourself.", "create returned unexpected value for key: message."
#   end

#   @tag id: 4
#   test "create write case here", context do
#     {:ok, result} = fetch_route(:post, "/api/friend", context)

#     assert result["status"] == "error", "create should have failed but didn't."
#     assert result["message"] ==  "Already in friends list.", "create returned unexpected value for key: message."
#   end

#   @tag id: 5
#   test "delete write case here", context do
#     {:ok, result} = fetch_route(:delete, "/api/friend", context)

#     assert result["status"] == "ok", "delete should have succeeded but didn't."
#     assert result["message"] ==  "Friend deleted.", "delete returned unexpected value for key: message."
#   end

#   @tag id: 6
#   test "delete write case here", context do
#     {:ok, result} = fetch_route(:delete, "/api/friend", context)

#     assert result["status"] == "error", "delete should have failed but didn't."
#     assert result["message"] ==  "This friend does not exist.", "delete returned unexpected value for key: message."
#   end

# end
