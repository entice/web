defmodule Entice.Web.TokenController do
  use Phoenix.Controller
  alias Entice.Web.Client
  alias Entice.Web.Token
  alias Entice.Logic.Area
  import Entice.Web.ControllerHelper
  import Phoenix.Naming

  plug :ensure_login
  plug :action


  def entity_token(conn, _params) do
    id = conn |> get_session(:client_id)

    {:ok, map_mod}   = Area.get_map(camelize(conn.params["map"]))
    {:ok, char}      = Client.get_char(id, conn.params["char_name"])
    {:ok, eid, _pid} = Entity.start()
    {:ok, token}     = Token.create_entity_token(id, %{entity_id: eid, area: map_mod, char: char})

    Player.init(eid, map_mod, char)

    conn |> json ok(%{
      message: "Transferring...",
      client_id: id,
      entity_token: token})
  end
end
