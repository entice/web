defmodule Entice.Web.FriendlistController do
	use Entice.Web.Web, :controller
	alias Entice.Web.Queries
	alias Entice.Web.Friend	



	@doc "Returns all friends of connected account."
	def index(conn, params) do
		id = get_session(conn, :client_id)

		friendlist = Queries.get_friendlist(id)

		conn |> json friendlist
	end

	@doc "Adds friend :name to friendlist of connected account."
	def create(conn, %{"name" => :name}) do
		id = get_session(conn, :client_id)

		result = case Queries.get_character(:name) do
			{:error, :no_matching_character} -> error(%{message: "This character does not exist."})
			{:ok, char} ->
				%Friend{friend_character_name: :name,
				 account_id: id,
				 friend_account_id: char.friend_account_id}
				 |> Entice.Web.Repo.insert
				ok(%{message: "Friend added succesfully."})
		end
		conn |> json result
	end

	def delete(conn, %{"name" => :name}) do
		id = get_session(conn, :client_id)

		result = case Queries.get_character(:name) do
			{:error, :no_matching_character} -> error(%{message: "This character does not exist."})
			{:ok, char} ->
				result2 = case Queries.get_friend(id, char.account_id) do

			ok(%{message: "Friend deleted succesfully."})
		end
		conn |> json result
	end



end 