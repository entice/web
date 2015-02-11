defmodule Entice.Web.SocialChannel do
  use Phoenix.Channel
  alias Entice.Web.Clients
  import Phoenix.Naming
  import Entice.Web.ChannelHelper


  def join("social:" <> map, %{"client_id" => id, "access_token" => token}, socket) do
    {:ok, ^token, :player, %{area: map_mod, entity_id: entity_id, char: char}} = Clients.get_token(id)
    {:ok, ^map_mod} = Area.get_map(camelize(map))

    socket = socket
      |> set_name(char.name)

    socket |> reply("join:ok", %{})
    {:ok, socket}
  end


  def handle_in("message", %{"text" => t}, socket) do
    broadcast(socket, "message", %{text: t, sender: socket |> name})
  end


  def handle_in("emote", %{"action" => a}, socket) do
    broadcast(socket, "emote", %{action: a, sender: socket |> name})
  end
end
