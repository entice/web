defmodule Entice.Web.GroupChannel do
  use Entice.Web.Web, :channel
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Logic.Area
  alias Entice.Logic.Group
  alias Entice.Web.Token
  alias Entice.Web.Discovery
  alias Entice.Web.Observer
  import Phoenix.Naming


  @reported_attributes [
    Leader,
    Member]


  def join("group:" <> map, %{"client_id" => client_id, "entity_token" => token}, socket) do
    case try_join(client_id, token, map, socket) do
      :ignore        -> :ignore
      {:ok, _} = res ->
        send(self, :after_join)
        res
    end
  end


  def handle_info(:after_join, socket) do
    :ok = Group.register(socket |> entity_id)

    attrs = Entity.take_attributes(socket |> entity_id, @reported_attributes)

    Discovery.register(socket |> entity_id)
    Discovery.discovery_request(
      socket |> map
      socket |> entity_id,
      attrs,
      [Leader])

    # listen for attribute changes from this entity
    Entity.add_attribute_listener(socket |> entity_id, self, false)

    # listen for events for this entity
    EntityTopic.subscribe(socket |> entity_id, self)
    MapTopic.subscribe(socket |> map, self)

    socket |> push("join:ok", %{})
    {:ok, socket}
  end


  # Internal events

  def handle_info({:DOWN, _ref, _type, _entity_pid, _info}, socket),
  do: {:stop, :normal, socket}


  def handle_info({:discovered, %{entity_id: entity_id, attributes: %{Leader => leader}}, socket) do
    socket |> push("update", %{
      leader: entity_id,
      members: leader.members,
      invited: leader.invited})
    {:noreply, socket}
  end


  def handle_info({:undiscovered, %{entity_id: entity_id, attributes: %{Leader => _}}, socket) do
    socket |> push("remove", %{entity: entity_id})
    {:noreply, socket}
  end


  def handle_info({:attribute_notify, %{
      entity_id: id,
      added: added,
      changed: changed,
      removed: removed}}, socket) do
    case Map.merge(added, changed) |> Map.get(Leader) do
      nil    -> :ok
      leader ->
        socket |> push("update", %{
          leader: entity_id,
          members: leader.members,
          invited: leader.invited})
    end
    {:noreply, socket}
  end


  def handle_info(_msg, socket), do: {:noreply, socket}

  def handle_info("mapchange", %{
      entity_id: _id,
      map: map_mod,
      attributes: %{Leader => %Leader{members: mems}}}, socket) do

    # if we are part of the members we need to leave the map as well
    if (socket |> entity_id) in mems do
      {:ok, _token} = Token.create_mapchange_token(socket |> client_id, %{
        entity_id: socket |> entity_id,
        map: map_mod,
        char: socket |> character})

      Observer.notify_mapchange(socket |> entity_id, map_mod)

      socket |> push("map:change", %{map: map_mod.underscore_name})
    end

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




  def handle_info(_event, _message, socket), do: {:ok, socket}


  def leave(_msg, socket) do
    Discovery.notify_inactive(socket |> entity_id, socket.topic, [Leader])
    Observer.notify_inactive(socket |> entity_id, socket.topic)
    Group.unregister(socket |> entity_id)
    {:ok, socket}
  end
end
