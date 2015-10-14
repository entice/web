defmodule Entice.Web.FriendsControllerTest do
  use Entice.Web.ConnCase
  alias Entice.Web.Queries

  setup context do
    result = %{email: "root@entice.ps", password: "root"}
    result = case context.id do
      0 -> Map.put(result, :params, %{})
      1 ->
        #Both accounts already each other's friends, we need to delete one to be able to add it again
        #All other tests working with root account so we don't want to touch it
        result = %{email: "test@entice.ps", password: "test"}
        {:ok, acc} = Queries.get_account(result.email, result.password)
        friend = hd(acc.friends)  #test2@entice.ps
        Entice.Web.Repo.delete!(friend)
        Map.put(result, :params, %{char_name: friend.base_name})
      2 -> Map.put(result, :params, %{char_name: "Char does not exist"})
      3 -> Map.put(result, :params, %{char_name: "Root Root A"})
      4 -> Map.put(result, :params, %{char_name: "Testc Testc A"})
      5 -> Map.put(result, :params, %{char_name: "Test Test A"})
      6 -> Map.put(result, :params, %{char_name: "Not a friend char"})
      _ -> Map.put(result, :params, %{})
    end
    {:ok, result}
  end

  @tag id: 0
  test "index success", context do
    {:ok, result} = fetch_route(:get, "/api/friend", context)

    assert result["status"] == "ok", "index should have succeeded but didn't."
    assert result["message"] ==  "All friends", "index returned unexpected value for key: message."
    assert result["friends"] !=  [], "index returned unexpected value for key: friends."
  end

  @tag id: 1
  test "create success", context do
    {:ok, result} = fetch_route(:post, "/api/friend", context)

    assert result["status"] == "ok", "create should have succeeded but didn't."
    assert result["message"] ==  "Friend added.", "create returned unexpected value for key: message."
  end

  @tag id: 2
  test "create character does not exist", context do
    {:ok, result} = fetch_route(:post, "/api/friend", context)

    assert result["status"] == "error", "create should have failed but didn't."
    assert result["message"] ==  "There is no character with that name", "create returned unexpected value for key: message."
  end

  @tag id: 3
  test "create adding own character", context do
    {:ok, result} = fetch_route(:post, "/api/friend", context)

    assert result["status"] == "error", "create should have failed but didn't."
    assert result["message"] ==  "Can't add yourself.", "create returned unexpected value for key: message."
  end

  @tag id: 4
  test "create character already friend", context do
    {:ok, result} = fetch_route(:post, "/api/friend", context)

    assert result["status"] == "error", "create should have failed but didn't."
    assert result["message"] ==  "Already in friends list.", "create returned unexpected value for key: message."
  end

  @tag id: 5
  test "delete success", context do
    {:ok, result} = fetch_route(:delete, "/api/friend", context)

    assert result["status"] == "ok", "delete should have succeeded but didn't."
    assert result["message"] ==  "Friend deleted.", "delete returned unexpected value for key: message."
  end

  @tag id: 6
  test "delete friend doesn't exist", context do
    {:ok, result} = fetch_route(:delete, "/api/friend", context)

    assert result["status"] == "error", "delete should have failed but didn't."
    assert result["message"] ==  "This friend does not exist.", "delete returned unexpected value for key: message."
  end

end
