defmodule Entice.Web.AccountController do
  use Entice.Web.Web, :controller
  alias Entice.Web.Account
  alias Entice.Web.Invitation
  alias Entice.Web.Queries
  require Logger

  plug :ensure_login when action in [:request_invite]

  def create(conn, _params) do
    email = conn.params["email"]
    password = conn.params["password"]
    invite_key = conn.params["inviteKey"]

    case Queries.get_invite(email) do
      
      {:error, :no_matching_invite} ->
        conn |> json error(%{message: "No Invitation found for this Email"})
        
      {:ok, invite} ->
        Logger.info invite.key
        Logger.info invite_key
        if invite.key != invite_key do
          conn |> json error(%{message: "Invalid Key!"})
        else
          Logger.info "Key Valid"
          %Account{email: email, password: password}
            |> Entice.Web.Repo.insert

          # Delte the used invite (no need to store them)
          Repo.delete(invite)
          conn |> json ok(%{message: "Account created!"})
        end

      _ ->
        conn |> json error(%{message: "Unknown Error occured"})
    end
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