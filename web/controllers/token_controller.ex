defmodule Entice.Web.TokenController do
  use Phoenix.Controller
  alias Entice.Web.Client
  alias Entice.Logic.Area
  import Entice.Web.ControllerHelper
  import Phoenix.Naming

  plug :ensure_login
  plug :action


  def player_token(conn, _params) do
    id = conn |> get_session(:client_id)

    {:ok, map_mod} = Area.get_map(camelize(conn.params["map"]))
    {:ok, char}  = Client.get_char(id, conn.params["char_name"])
    {:ok, token} = Client.create_token(id, :player, %{area: map_mod, char: char})

    conn |> json ok(%{
      message: "Transferring...",
      client_id: id,
      player_token: token})
  end
end
