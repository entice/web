defmodule Entice.Web.EntityChannel do
  use Phoenix.Channel
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Web.Client
  alias Entice.Web.Token
  alias Entice.Web.Player
  alias Entice.Web.Dump
  import Phoenix.Naming
  import Entice.Web.ChannelHelper


  # Initializing the connection


  def join("entity:" <> map, %{"client_id" => client_id, "entity_token" => token}, socket) do
    {:ok, ^token, :entity, %{entity_id: entity_id, area: map_mod, char: char}} = Token.get_token(client_id)
    {:ok, ^map_mod} = Area.get_map(camelize(map))
    Token.delete_token(client_id)

    # fetch a dump of the state of pther entities
    :ok = Dump.init(entity_id, map_mod)
    Dump.notify_added(entity_id, map_mod)

    socket = socket
      |> set_area(map_mod)
      |> set_entity_id(entity_id)
      |> set_client_id(client_id)
      |> set_character(char)

    socket |> reply("join:ok", %{entity: entity_id})
    {:ok, socket}
  end


  # Outgoing Event API


  def handle_out("entity_dump",  %{new: new_entity_id, existing: entity_id, attributes: attributes}, socket) do
    if (new_entity_id == socket |> entity_id),
    do: socket |> reply("entity:add", %{entity_id: entity_id, attributes: attributes})
    {:ok, socket}
  end


  def handle_out(_event, _message, socket), do: {:ok, socket}


  # Socket leave


  def leave(_msg, socket) do
    Dump.remove(socket |> entity_id)
    Player.stop(socket |> area, socket |> entity_id)
    {:ok, socket}
  end
end
