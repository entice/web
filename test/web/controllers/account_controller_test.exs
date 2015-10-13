defmodule Entice.Web.AccountControllerTest do
  use Entice.Web.ConnCase
  alias Entice.Web.Invitation

  setup context do
    result = %{email: "root@entice.ps", password: "root" }
    result = case context.id do
      1 -> Map.put(result, :params, %{char_name: "name does not exist"})
      2 -> Map.put(result, :params, %{char_name: "root 1"})
      3 -> Map.put(result, :params, %{email: "root@entice.ps"})
      4 ->
        email = "email@email.com"
        key = UUID.uuid4()
        %Invitation{email: email, key: key} |> Entice.Web.Repo.insert
        Map.put(result, :params, %{email: email, key: key})
      5 -> Map.put(result, :params, %{email: "new_email@email.com"})
      6 -> Map.put(result, :params, %{email: "was not invited", password: "p", invite_key: "k"})
      7 ->
        email = "was invited"
        password = "p"
        invite_key = "wrong key"
        key = UUID.uuid4()
        %Invitation{email: email, key: key} |> Entice.Web.Repo.insert
        Map.put(result, :params, %{email: email, password: password, invite_key: invite_key})
      8 ->
        email = "was invited too"
        password = "p"
        key = UUID.uuid4()
        %Invitation{email: email, key: key} |> Entice.Web.Repo.insert
        Map.put(result, :params, %{email: email, password: password, invite_key: key})
      _ -> Map.put(result, :params, %{})
    end
    {:ok, result}
  end

  @tag id: 1
  test "by_char_name wrong char name", context do
    {:ok, result} = fetch_route(:get, "/api/account/by_char_name", context)

    assert result["status"] == "error", "by_char_name should have failed but didn't."
    assert result["message"] == "Couldn't find character.", "by_char_name did not fail in the expected way."
  end

  @tag id: 2
  test "by_char_name existing char name", context do
    {:ok, result} = fetch_route(:get, "/api/account/by_char_name", context)

    assert result["status"] == "ok", "by_char_name should have succeeded but didn't."
  end

  @tag id: 3
  test "request_invite email already in use", context do
    {:ok, result} = fetch_route(:post, "/api/account/request", context)

    assert result["status"] == "error", "request_invite should have failed but didn't."
    assert result["message"] == "This Email address is already in use", "request_invite did not fail in the expected way."
  end

  @tag id: 4
  test "request_invite already invited", context do
    {:ok, result} = fetch_route(:post, "/api/account/request", context)

    assert result["status"] == "ok", "request_invite should have succeeded but didn't."
    assert result["message"] == "Invite exists already", "request_invite did not succeed in the expected way."
    assert result["key"] == context.params.key, "request_invite did not return the right key."
    assert result["email"] == context.params.email, "request_invite did not return the right email."
  end

  @tag id: 5
  test "request_invite correct parameters", context do
    {:ok, result} = fetch_route(:post, "/api/account/request", context)

    assert result["status"] == "ok", "request_invite should have succeeded but didn't."
    assert result["message"] == "Invite Created", "request_invite did not succeed in the expected way."
    assert result["email"] == context.params.email, "request_invite did not return the right email."
  end

  @tag id: 6
  test "register no invite", context do
    {:ok, result} = fetch_route(:post, "/api/account/register", context)

    assert result["status"] == "error", "register should have failed but didn't."
    assert result["message"] == "No Invitation found for this Email", "register did not fail in the expected way."
  end

  @tag id: 7
  test "register wrong key", context do
    {:ok, result} = fetch_route(:post, "/api/account/register", context)

    assert result["status"] == "error", "register should have failed but didn't."
    assert result["message"] == "Invalid Key!", "register did not fail in the expected way."
  end

  @tag id: 8
  test "register correct parameters", context do
    {:ok, result} = fetch_route(:post, "/api/account/register", context)

    assert result["status"] == "ok", "register should have succeeded but didn't."
    assert result["message"] == "Account created!", "register did not succeed in the expected way."
  end
end
