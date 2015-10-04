defmodule Entice.Web.AuthControllerTest do
  use Entice.Web.ConnCase

  setup context do
    result = %{email: "root@entice.ps", password: "root" }
    result = case context.id do
      0 -> Map.put(result, :params, %{email: "root@entice.ps", password: "root"})
      1 -> Map.put(result, :params, %{email: "root@entice.ps", password: "root"})
      2 -> Map.put(result, :params, %{email: "root@entice.ps", password: "wrong pass"})
      3 -> Map.put(result, :params, %{email: "root@entice.ps", password: "root"})
      _ -> Map.put(result, :params, %{email: "root@entice.ps", password: "root"})
    end
    {:ok, result}
  end

  @tag id: 0
  test "login already logged in", context do
    {:ok, result} = fetch_route(:post, "/api/login", context)

    assert result["status"] == "error", "login should have failed but didn't."
    assert result["message"] ==  "Already logged in.", "login returned unexpected value for key: message."
  end

  @tag id: 1
  test "login correct parameters", context do
    {:ok, result} = fetch_route(:post, "/api/login", context, False)

    assert result["status"] == "ok", "login should have succeeded but didn't."
    assert result["message"] ==  "Logged in.", "login returned unexpected value for key: message."
  end

  @tag id: 2
  test "login wrong pass", context do
    {:ok, result} = fetch_route(:post, "/api/login", context, False)

    assert result["status"] == "error", "login should have failed but didn't."
    assert result["message"] ==  "Authentication failed.", "login returned unexpected value for key: message."
  end

  @tag id: 3
  test "logout correct parameters", context do
    {:ok, result} = fetch_route(:post, "/api/logout", context)

    assert result["status"] == "ok", "logout should have succeeded but didn't."
    assert result["message"] ==  "Logged out.", "logout returned unexpected value for key: message."
  end

  @tag id: 4
  test "logout already logged out", context do
    {:ok, result} = fetch_route(:post, "/api/logout", context, False)

    assert result["status"] == "error", "logout should have failed but didn't."
    assert result["message"] ==  "Already logged out.", "logout returned unexpected value for key: message."
  end

end
