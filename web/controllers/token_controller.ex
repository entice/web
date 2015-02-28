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

    # create the token (or use the mapchange token)
    token = case Token.get_token(id) do
      {:ok, token, :mapchange, %{entity_id: _, map: _, char: _} = t} -> %{t | token: token}
      _ ->
        {:ok, map_mod}   = Area.get_map(camelize(conn.params["map"]))
        {:ok, char}      = Client.get_char(id, conn.params["char_name"])
        {:ok, eid, _pid} = Entity.start()
        {:ok, token}     = Token.create_entity_token(id, %{entity_id: eid, map: map_mod, char: char})
        %{token: token, entity_id: eid, map: map_mod, char: char}
    end

    # init the entity and update the client
    Client.set_entity(id, token[:entity_id])
    Player.init(token[:entity_id], token[:map], token[:char])

    conn |> json ok(%{
      message: "Transferring...",
      client_id: id,
      entity_id: token[:entity_id],
      entity_token: token[:token]})
  end
end
