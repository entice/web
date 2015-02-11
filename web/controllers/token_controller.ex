defmodule Entice.Web.TokenController do
  use Phoenix.Controller
  alias Entice.Web.Clients
  alias Entice.Area
  import Entice.Web.Auth
  import Entice.Web.ControllerHelper
  import Phoenix.Naming

  plug :ensure_login
  plug :action


  def player_token(conn, _params) do
    id = conn |> get_session(:client_id)

    {:ok, map_mod} = Area.get_map(camelize(conn.params["map"]))
    {:ok, char}  = Clients.get_char(id, conn.params["char_name"])
    {:ok, token} = Clients.create_token(id, :area, %{area: map_mod, char: char})

    conn |> json ok(%{
      message: "Transferring...",
      client_id: id,
      player_token: token})
  end
end
