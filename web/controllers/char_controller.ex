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


  def create(conn, %{"char_name" => name} = params) do
    id = conn |> get_session(:client_id)
    {:ok, acc} = Client.get_account(id)

    changeset = Character.changeset_char_create(%Character{account_id: acc.id}, Map.put(params, "name", name))
    char = Entice.Web.Repo.insert(changeset)

    result =
      case char do
        {:error, %{errors: [name: "has already been taken"]}} -> error(%{message: "Could not create char. The name is already in use."})
        {:error, %{errors: errors}}                           -> error(%{message: "Errors occured: #{inspect errors}"})
        {:error, _reason}                                     -> error(%{message: "Unknown error occured."})
        {:ok, char} ->
          # make sure the account has the new char...
          {:ok, _char} = Client.get_char(id, char.name)
          ok(%{message: "Char created.", character: char |> Map.from_struct |> Map.take(@field_whitelist)})
      end

    conn |> json result
  end
end
