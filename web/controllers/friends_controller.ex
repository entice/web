defmodule Entice.Web.FriendsController do
  use Entice.Web.Web, :controller
  alias Entice.Web.Queries
  alias Entice.Web.Friend 



  @doc "Returns all friends of connected account."
  def index(conn, _params) do
    id = get_session(conn, :client_id)

    friendlist = Queries.get_friendlist(id)

    conn |> json friendlist
  end


  @doc "Adds friend :id to friends list of connected account."
  def create(conn, %{"id" => id}) do
    account_id = get_session(conn, :client_id)

    result = case Queries.get_account(id) do
      {:error, :no_matching_account} -> error(%{message: "This character does not exist."})
      {:ok, _account} ->
        %Friend{friend_account_id: id, account_id: account_id}
        |> Entice.Web.Repo.insert
        ok(%{message: "Friend added."})
    end
    conn |> json result
  end
      
  @doc "Deletes friend :id from friends list of connected account."
  def delete(conn, %{"id" => id}) do
    account_id = get_session(conn, :client_id)

    result = case Queries.get_friend(account_id, id) do
      {:error, :no_matching_friend} -> error(%{message: "This friend does not exist."})
      {:ok, friend} ->
        Entice.Web.Repo.delete(friend)
        ok(%{message: "Friend deleted."})
    end
    conn |> json result
  end



end 