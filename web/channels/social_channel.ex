defmodule Entice.Web.SocialChannel do
  use Phoenix.Channel
  use Entice.Logic.Area
  alias Entice.Web.Client
  alias Entice.Web.Token
  import Phoenix.Naming
  import Entice.Web.ChannelHelper


  def join("social:" <> map, %{"client_id" => id, "entity_token" => token}, socket) do
    {:ok, ^token, :entity, %{map: map_mod, entity_id: entity_id, char: char}} = Token.get_token(id)
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
