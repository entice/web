defmodule Entice.Web.EntityChannel do
  use Phoenix.Channel
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Entity
  alias Entice.Web.Token
  alias Entice.Web.Player
  alias Entice.Web.Discovery
  import Phoenix.Naming
  import Entice.Web.ChannelHelper


  # Initializing the connection


  def join("entity:" <> map, %{"client_id" => client_id, "entity_token" => token}, socket) do
    {:ok, ^token, :entity, %{entity_id: entity_id, area: map_mod, char: char}} = Token.get_token(client_id)
    {:ok, ^map_mod} = Area.get_map(camelize(map))

    Phoenix.PubSub.subscribe(socket.pubsub_server, socket.pid, "entity:" <> map, link: true)

    # fetch a dump of the state of other entities
    Discovery.init(entity_id, map_mod)
    Discovery.notify_active(entity_id, "group:" <> map, [Name, Position, Appearance])

    attrs = Player.attributes(entity_id)

    socket = socket
      |> set_area(map_mod)
      |> set_entity_id(entity_id)
      |> set_client_id(client_id)
      |> set_character(char)

    socket |> reply("join:ok", %{
      name:       attrs[Name].name,
      position:   Map.from_struct(attrs[Position].pos),
      appearance: Map.from_struct(attrs[Appearance])})

    {:ok, socket}
  end


  # Outgoing Event API


  def handle_out("discovered", %{
      recipient: rec_id,
      entity_id: entity_id,
      attributes: %{Name => name, Position => pos, Appearance => appear}},
      socket) do

    if (rec_id == socket |> entity_id),
    do: socket |> reply("add", %{
      entity_id:  entity_id,
      name:       name.name,
      position:   Map.from_struct(pos.pos),
      appearance: Map.from_struct(appear)})

    {:ok, socket}
  end


  def handle_out("undiscovered", %{recipient: rec_id, entity_id: entity_id}, socket) do
    if (rec_id == socket |> entity_id),
    do: socket |> reply("remove", %{entity_id: entity_id})
    {:ok, socket}
  end


  def handle_out(_event, _message, socket), do: {:ok, socket}


  # Socket leave


  def leave(_msg, socket) do
    Discovery.notify_inactive(socket |> entity_id, socket.topic, [Name, Position, Appearance])
    Entity.stop(socket |> entity_id)
    {:ok, socket}
  end
end
