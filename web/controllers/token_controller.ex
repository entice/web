defmodule Entice.Web.TokenController do
  use Phoenix.Controller
  alias Entice.Web.Client
  alias Entice.Web.Player
  alias Entice.Web.Token
  alias Entice.Logic.Area
  alias Entice.Entity
  import Entice.Web.ControllerHelper
  import Phoenix.Naming

  plug :ensure_login
  plug :action


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

    # create the token (or use the mapchange token)
    :ok = case Token.get_token(id) do
      {:ok, _token, :mapchange, %{entity_id: _old_entity_id, map: ^map_mod, char: ^char}} -> :ok
      {:ok, _token, :entity, _data} -> :ok
      {:error, :token_not_found} -> :ok
      token ->
        raise "Token did not match expectations. Map: #{inspect map_mod}, Char: #{inspect char}, Actual: #{inspect token}"
    end

    {:ok, token} = Token.create_entity_token(id, %{entity_id: eid, map: map_mod, char: char})

    # init the entity and update the client
    Client.set_entity(id, eid)
    Player.init(eid, map_mod, char)

    conn |> json ok(%{
      message: "Transferring...",
      client_id: id,
      entity_id: eid,
      entity_token: token})
  end
end
