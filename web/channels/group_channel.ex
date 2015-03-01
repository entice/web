defmodule Entice.Web.GroupChannel do
  use Phoenix.Channel
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Logic.Area
  alias Entice.Logic.Group
  alias Entice.Web.Token
  alias Entice.Web.Discovery
  alias Entice.Web.Observer
  alias Entice.Web.Player
  import Phoenix.Naming
  import Entice.Web.ChannelHelper


  def join("group:" <> map, %{"client_id" => client_id, "entity_token" => token}, socket) do
    {:ok, ^token, :entity, %{map: map_mod, entity_id: entity_id, char: char}} = Token.get_token(client_id)
    {:ok, ^map_mod} = Area.get_map(camelize(map))

    Phoenix.PubSub.subscribe(socket.pubsub_server, socket.pid, "group:" <> map, link: true)

    Discovery.init(entity_id, map_mod)
    Discovery.notify_active(entity_id, "group:" <> map, [Leader])

    Observer.init(entity_id)
    Observer.notify_active(entity_id, "group:" <> map, [Leader])

    Player.add_listener(entity_id, "group:" <> map)

    :ok = Group.init(entity_id)

    socket = socket
      |> set_map(map_mod)
      |> set_entity_id(entity_id)
      |> set_client_id(client_id)
      |> set_character(char)

    socket |> reply("join:ok", %{})
    {:ok, socket}
  end


  # Incoming events


  def handle_in("merge", %{"target" => id}, socket) do
    Group.invite(socket |> entity_id, id)
    {:ok, socket}
  end


  def handle_in("kick", %{"target" => id}, socket) do
    Group.kick(socket |> entity_id, id)
    {:ok, socket}
  end


  # Outgoing events


  def handle_out("observed", %{entity_id: entity_id, attributes: %{Leader => %Leader{members: mems, invited: invs}}}, socket) do
    socket |> reply("update", %{
      leader: entity_id,
      members: mems,
      invited: invs})
    {:ok, socket}
  end


  def handle_out("discovered", %{recipient: rec_id, entity_id: entity_id, attributes: %{Leader => leader}}, socket) do
    if (rec_id == socket |> entity_id),
    do: socket |> reply("update", %{
      leader: entity_id,
      members: leader.members,
      invited: leader.invited})
    {:ok, socket}
  end


  def handle_out("missed", %{entity_id: entity_id, attributes: attrs}, socket) do
    if Leader in attrs, do: socket |> reply("remove", %{entity: entity_id})
    {:ok, socket}
  end


  def handle_out("mapchange", %{
      entity_id: _id,
      map: map_mod,
      attributes: %{Leader => %Leader{members: mems}}}, socket) do

    # if we are part of the members we need to leave the map as well
    if (socket |> entity_id) in mems do
      {:ok, _token} = Token.create_mapchange_token(socket |> client_id, %{
        entity_id: socket |> entity_id,
        map: map_mod,
        char: socket |> character})

      Player.notify_mapchange(socket |> entity_id, map_mod)

      socket |> reply("map:change", %{map: map_mod.underscore_name})
    end

    {:ok, socket}
  end


  def handle_out(_event, _message, socket), do: {:ok, socket}


  def leave(_msg, socket) do
    Discovery.notify_inactive(socket |> entity_id, socket.topic, [Leader])
    Observer.notify_inactive(socket |> entity_id, socket.topic)
    Player.remove_listener(socket |> entity_id, socket.topic)
    Group.remove(socket |> entity_id)
    {:ok, socket}
  end
end
