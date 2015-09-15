defmodule Entice.Web.AccountController do
  use Entice.Web.Web, :controller
  alias Entice.Web.Account
  alias Entice.Web.Invitation
  alias Entice.Web.Queries

  plug :ensure_login when action in [:request_invite]

  def create(conn, _params) do
    email = conn.params["email"]
    password = conn.params["password"]
    userKey = conn.params["inviteKey"]

    result = case Queries.get_invite(email) do    
      {:error, :no_matching_invite} ->
        error(%{message: "No Invitation found for this Email"})
      {:ok, %Invitation{key: key}} when key != userKey ->
        error(%{message: "Invalid Key!"})
      {:ok, invite} ->
        %Account{email: email, password: password}
          |> Entice.Web.Repo.insert
        # Delete the used invite (no need to store them)
        Repo.delete(invite)
        ok(%{message: "Account created!"})
      _ ->
        error(%{message: "Unknown Error occured"})
    end
    conn |> json result
  end

  def request_invite(conn, _params) do
    email = conn.params["email"]
    result = case {Queries.get_account(email), Queries.get_invite(email)} do
      {{:ok, _account}, _} -> error(%{message: "This Email address is already in use"})
      {_, {:ok, invite}}   -> ok(%{message: "Invite exists already", email: invite.email, key: invite.key})
      {_, {:error, :no_matching_invite}} ->
        {:ok, invite} = %Invitation{email: email, key: UUID.uuid4()} |> Entice.Web.Repo.insert
        ok(%{message: "Invite Created", email: invite.email, key: invite.key})
    end
    conn |> json result
  end
end