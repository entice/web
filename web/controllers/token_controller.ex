defmodule Entice.Web.TokenController do
  use Entice.Web.Web, :controller
  alias Entice.Entity
  alias Entice.Logic.Area
  alias Entice.Logic.Player
  alias Entice.Logic.Player.Appearance
  alias Entice.Web.Character
  alias Entice.Web.Token
  import Entice.Utils.StructOps
  import Phoenix.Naming

  plug :ensure_login


  def entity_token(conn, _params) do
    id = get_session(conn, :client_id)

    # make sure any old entities are killed before being able to play
    case Client.get_entity(id) do
      old when is_bitstring(old) -> Entity.stop(old)
      _ ->
    end

    {:ok, map_mod}   = Area.get_map(camelize(conn.params["map"]))
    {:ok, char}      = Client.get_char(id, conn.params["char_name"])
    {:ok, eid, _pid} = Entity.start()
    name = char.name

    # check if the player already has a mapchange token set
    :ok = case Token.get_token(id) do
      {:ok, _token, :mapchange, %{entity_id: _old_entity_id, map: ^map_mod, char: %Character{name: ^name}}} -> :ok
      {:ok, _token, :entity, _data} -> :ok
      {:error, :token_not_found} -> :ok
      token ->
        raise "Token did not match expectations. Map: #{inspect map_mod}, Char: #{inspect char}, Actual: #{inspect token}"
    end

    # create the token (or use the mapchange token)
    {:ok, token} = Token.create_entity_token(id, %{entity_id: eid, map: map_mod, char: char})

    # init the entity and update the client
    Client.set_entity(id, eid)
    Player.register(eid, map_mod, char.name, copy_into(%Appearance{}, char))

    conn |> json ok(%{
      message: "Transferring...",
      client_id: id,
      entity_id: eid,
      entity_token: token,
      map: map_mod.underscore_name,
      is_outpost: map_mod.is_outpost?})
  end
end
