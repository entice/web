defmodule Entice.Web.AccountController do
  use Entice.Web.Web, :controller
  alias Entice.Web.Account
  alias Entice.Web.Invitation
  alias Entice.Web.Queries


  plug :ensure_login when action in [:request_invite]

  defp register(conn, %{"email" => email, "password" => password, "inviteKey" => invite_key}) do
    result = case Queries.get_invite(email) do
      {:ok, %Invitation{key: ^invite_key} = invite} ->
        %Account{email: email, password: password} |> Entice.Web.Repo.insert
        # Delete the used invite (no need to store them)
        Repo.delete(invite)
        ok(%{message: "Account created!"})
      {:ok, _}                      -> error(%{message: "Invalid Key!"})
      {:error, :no_matching_invite} -> error(%{message: "No Invitation found for this Email"})
      _                             -> error(%{message: "Unknown Error occured"})
    end
    conn |> json result
  end

  def request_invite(conn, %{"email" => email}) do
    result = case {Queries.get_account(email), Queries.get_invite(email)} do
      {{:ok, _account}, _} -> error(%{message: "This Email address is already in use"})
      {_, {:ok, invite}}   -> ok(%{message: "Invite exists already", email: invite.email, key: invite.key})
      {_, {:error, :no_matching_invite}} ->
        {:ok, invite} = %Invitation{email: email, key: UUID.uuid4()} |> Entice.Web.Repo.insert
        ok(%{message: "Invite Created", email: invite.email, key: invite.key})
    end
    conn |> json result
  end

  @doc "Gets the account id of a character by name (passed through conn) ."
  def by_char_name(conn, %{"char_name" => char_name}) do
    result = case Queries.get_account_id(char_name) do
      {:error, :no_matching_character} -> error(%{message: "Couldn't find character."})
      {:ok, account_id} -> ok(%{account_id: account_id})
    end

    conn |> json result
  end
end
