defmodule Entice.Web.CharController do
  use Entice.Web.Web, :controller
  alias Entice.Web.Character

  plug :ensure_login


  @field_whitelist [
    :name,
    :available_skills,
    :skillbar,
    :profession,
    :campaign,
    :sex,
    :height,
    :skin_color,
    :hair_color,
    :hairstyle,
    :face]


  def list(conn, _params) do
    id = conn |> get_session(:client_id)
    {:ok, acc} = Client.get_account(id)

    chars = acc.characters
    |> Enum.map(fn char ->
      char
      |> Map.from_struct
      |> Map.take(@field_whitelist)
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
end