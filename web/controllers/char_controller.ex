defmodule Entice.Web.CharController do
  use Entice.Web.Web, :controller
  alias Entice.Web.Character

  plug :ensure_login


  def list(conn, _params) do
    id = conn |> get_session(:client_id)
    {:ok, acc} = Client.get_account(id)

    chars = acc.characters
    |> Enum.map(fn char ->
      char
      |> Map.from_struct
      |> Map.delete(:id)
      |> Map.delete(:account)
      |> Map.delete(:account_id)
    end)

    conn |> json ok(%{
      message: "All chars...",
      characters: chars})
  end


  def create(conn, _params) do
    id = conn |> get_session(:client_id)
    {:ok, acc} = Client.get_account(id)

    name = conn.params["name"]
    char = %Character{name: name, account: acc} |> Entice.Web.Repo.insert

    Client.add_char(id, char)

    conn |> json ok(%{
      message: "Char created.",
      character: char})
  end

  @doc "Gets the account id of the character named :name ."
  def get_account(conn, %{"name" => :name}) do
    result = case Queries.get_account_id(:name) do
      {:error, :no_matching_character} -> error(%{message: "Couldn't find character."})
      {:ok, account_id} -> ok(%{account_id: account_id})
    end

    conn |> json result
  end

end
