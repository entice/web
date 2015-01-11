defmodule Entice.Web.TokenController do
  use Phoenix.Controller
  alias Entice.Web.Clients
  alias Entice.Area
  import Entice.Web.Auth
  import Entice.Web.ApiMessage
  import Phoenix.Naming

  plug :ensure_login
  plug :action


  def area_transfer_token(conn, _params) do
    id = conn |> get_session(:client_id)

    {:ok, map_mod} = Area.get_map(camelize(conn.params["map"]))
    {:ok, char}  = Clients.get_char(id, conn.params["char_name"])
    {:ok, token} = Clients.create_transfer_token(id, :area, %{area: map_mod, char: char})

    conn |> send_token(id, token)
  end

  def social_transfer_token(conn, _params) do
    id = conn |> get_session(:client_id)

    {:ok, char}  = Clients.get_char(id, conn.params["char_name"])
    {:ok, token} = Clients.create_transfer_token(id, :social, %{room: conn.params["room"], char: char})

    conn |> send_token(id, token)
  end


  defp send_token(conn, client_id, token) do
    conn |> json ok(%{
      message: "Transferring...",
      client_id: client_id,
      transfer_token: token})
  end
end
