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
    profession = conn.params["profession"] || 1
    campaign = conn.params["campaign"] || 0
    sex = conn.params["sex"] || 1
    height = conn.params["height"] || 0
    skin_color = conn.params["skin_color"] || 3
    hair_color = conn.params["hair_color"] || 0
    hairstyle = conn.params["hairstyle"] || 7
    face = conn.params["face"] || 30

    char = %Character{
      name: name,
      account: acc,
      profession: profession,
      campaign: campaign,
      sex: sex,
      height: height,
      skin_color: skin_color,
      hair_color: hair_color,
      hairstyle: hairstyle,
      face: face} |> Entice.Web.Repo.insert

    result =
      case char do
        {:error, _reason} -> error(%{message: "Could not create char. Maybe the name is already taken?"})
        {:ok, char} ->
          Client.add_char(id, char)
          ok(%{message: "Char created.", character: char |> Map.from_struct |> Map.take(@field_whitelist)})
      end

    conn |> json result
  end
end
