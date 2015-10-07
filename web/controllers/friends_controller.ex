defmodule Entice.Web.FriendsController do
  use Entice.Web.Web, :controller
  alias Entice.Web.Queries
  alias Entice.Web.Account

  plug :ensure_login

  #Case to think about:
  #Player A adds friend Player B under name N
  #Player B deletes account (and so all chars are deleted)
  #Player C creates acccount and char under name N
  #Player A adds Player C under name N
  #Now in friends DB: (N, PlayerA.id, PlayerB.id) and (N, PlayerA.id, PlayerC.id)
  #Since all queries are done by name it'll be an issue.
  #Solutions:
  #Delete all friends with PlayerB.id in them


  #TODO: add map once it's server sided, order by creation date
  @doc "Returns all friends of connected account."
  def index(conn, _params) do
    id = get_session(conn, :client_id)
    {:ok, friends} = Entice.Web.Client.get_friends(id)

    results = []
    results = for friend <- friends do
      {:ok, status, name} = get_status(friend.base_name)
      map = %{base_name: friend.base_name, current_name: name, status: status}
      results = results ++ [map]
    end

    conn |> json ok(%{
      message: "All friends",
      friends: results})
  end

  defp get_status(friend_name) do
    {:ok, status, name} = Client.get_status(friend_name)
  end

  @doc "Adds friend :id to friends list of connected account."
  def create(conn, _params) do
    session_id = get_session(conn, :client_id)
    {:ok, acc} = Client.get_account(session_id)
    account_id = acc.id
    friend_name = conn.params["char_name"]

    result = case Queries.get_account_by_name(friend_name) do
      {:error, _} -> error(%{message: "There is no character with that name"})
      {:ok, %Account{id: ^account_id}} -> error(%{message: "Can't add yourself."})
      {:ok, friend_account} ->
        #Important to get by friend_id and not name here or player will be able to add same account under dif names.
        case Queries.get_friend_by_friend_account_id(account_id, friend_account.id) do
          {:error, :no_matching_friend} ->
            Queries.add_friend(acc, friend_account, friend_name)
            ok(%{message: "Friend added."})
          {:ok, _friend} -> error(%{message: "Already in friends list."})
        end
    end
    conn |> json result
  end

  @doc "Deletes friend :id from friends list of connected account."
  def delete(conn, _params) do
    session_id = get_session(conn, :client_id)
    {:ok, acc} = Client.get_account(session_id)
    friend_name = conn.params["char_name"]

    #friend_name will always be base_name of friend model since query controller by client, so no need to get friend by id
    result = case Queries.get_friend_by_base_name(acc.id, friend_name) do
      {:error, :no_matching_friend} -> error(%{message: "This friend does not exist."})
      {:ok, friend} ->
        Entice.Web.Repo.delete(friend)
        ok(%{message: "Friend deleted."})
    end
    conn |> json result
  end
end
