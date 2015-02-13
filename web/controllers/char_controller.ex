defmodule Entice.Web.CharController do
  use Phoenix.Controller
  alias Entice.Web.Character
  alias Entice.Web.Client
  import Entice.Web.ControllerHelper

  plug :ensure_login
  plug :action


  def list(conn, _params) do
    id = conn |> get_session(:client_id)
    {:ok, acc} = Client.get_account(id)

    chars = acc.characters
    |> Enum.map(&Map.from_struct/1)
    |> Enum.map(&Map.delete(&1, :id))
    |> Enum.map(&Map.delete(&1, :account))
    |> Enum.map(&Map.delete(&1, :account_id))

    conn |> json ok(%{
      message: "All chars...",
      characters: chars})
  end


  def create(conn, _params) do
    id = conn |> get_session(:client_id)
    {:ok, acc} = Client.get_account(id)

    name = conn.params["name"]
    char = %Character{name: name, account: acc}
      |> Entice.Web.Repo.insert

    Client.add_char(id, char)

    conn |> json ok(%{
      message: "Char created.",
      character: char})
  end
end
