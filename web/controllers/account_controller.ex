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
      
      {:ok, invite} ->

        if invite.key != invite_key do
          conn |> json error(%{message: "Invalid Key!"})
        else
          Logger.info "Key Valid"
          %Account{email: email, password: password}
            |> Entice.Web.Repo.insert

          Repo.delete(invite)

          conn |> json ok(%{message: "Account created!"})
        end
      {:error, :no_matching_invite} ->
        conn |> json error(%{message: "No Invitation found for this Email"})
      
      _ ->
        conn |> json error(%{message: "Unknown Error occured"})
    end
  end

  def request_invite(conn, _params) do
    email = conn.params["email"]
    # Check if a Account with this Email already exists
    case Queries.check_existing_account(email) do
        {:ok, :account_not_found} ->
          # Check if a invite is already sent to this email
          case Queries.get_invite(email) do
            {:error, :no_matching_invite} ->
              key = UUID.uuid4()
              invite = %Invitation{email: email, key: key}
                |> Entice.Web.Repo.insert
              conn |> json ok(%{message: "Invite Created", email: email, key: key})

              {:ok, count}->
                conn |> json error(%{message: "A invite is already sent to this Email."})
            end
        {:ok, count} ->
          conn |> json error(%{message: "This Email address is already in use"})  
    end
  end
end