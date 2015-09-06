defmodule Entice.Web.EntityChannel do
  use Entice.Web.Web, :channel
  use Entice.Logic.Attributes
  alias Entice.Utils.StructOps
  alias Entice.Entity
  alias Entice.Entity.Discovery
  alias Entice.Logic.Player
  alias Entice.Web.EntityTopic
  alias Entice.Web.MapTopic


  @reported_attributes [
    Position,
    Name,
    Appearance,
    Health,
    Energy]


  def join("entity:" <> map, _message, %Socket{assigns: %{map: map}} = socket) do
    Process.flag(:trap_exit, true)
    send(self, :after_join)
    {:ok, socket}
  end


  def handle_info(:after_join, socket) do
    {:ok, entity_pid} = Entity.fetch(socket |> entity_id)
    Process.monitor(entity_pid)

    attrs = Player.attributes(socket |> entity_id)

    # try discover the state of other entities
    Discovery.register(socket |> entity_id)
    Discovery.discovery_request(
      socket |> map,
      socket |> entity_id,
      attrs,
      @reported_attributes)

    # listen for attribute changes from this entity
    Entity.add_attribute_listener(socket |> entity_id, self, false)

    # listen for events for this entity
    MapTopic.subscribe(socket |> map, self)

    socket |> push("join:ok", %{attributes: process_attributes(attrs)})
    {:noreply, socket}
  end


  # Internal events


  def handle_info({:DOWN, _ref, _type, _entity_pid, _info}, socket),
  do: {:stop, :normal, socket}


  def handle_info({:discovered, %{entity_id: entity_id, attributes: attrs}}, socket) do
    res = process_attributes(attrs)
    if not Enum.empty?(res) do
      Entity.add_attribute_listener(entity_id, self, false)
      socket |> push("add", %{
        entity: entity_id,
        attributes: res})
    end
    {:noreply, socket}
  end


  def handle_info({:undiscovered, %{entity_id: entity_id, attributes: attrs}}, socket) do
    res = process_attributes(attrs)
    if not Enum.empty?(res),
    do: socket |> push("remove", %{entity: entity_id})
    {:noreply, socket}
  end


  def handle_info({:attribute_notify, %{
      entity_id: id,
      added: added,
      changed: changed,
      removed: removed}}, socket) do
    res = [
      process_attributes(added),
      process_attributes(changed),
      process_attributes(removed)]
    if res |> Enum.any?(&(not Enum.empty?(&1))) do
      socket |> push("change", %{
        entity: id,
        added: res |> Enum.at(0),
        changed: res |> Enum.at(1),
        removed: res |> Enum.at(2)})
    end
    {:noreply, socket}
  end


  def handle_info(_msg, socket), do: {:noreply, socket}


  # Incoming from the net


  def handle_in("map:change", %{"map" => map}, socket) do
    {:ok, map_mod} = Area.get_map(camelize(map))
    {:ok, _token}  = Token.create_mapchange_token(socket |> client_id, %{
      entity_id: socket |> entity_id,
      map: map_mod,
      char: socket |> character})

    EntityTopic.broadcast_mapchange(socket |> entity_id, map_mod)

    {:reply, {:ok, %{map: map}}, socket}
  end


  # Leaving the socket (voluntarily or forcefully)


  def terminate(_msg, socket) do
    attrs = Player.attributes(socket |> entity_id)

    MapTopic.unsubscribe(socket |> map, self)
    EntityTopic.unsubscribe(socket |> entity_id, self)
    Discovery.undiscover_notify(socket |> map, socket |> entity_id, attrs)
    Entity.stop(socket |> entity_id)
    :ok
  end


  # Internal


  # Transform attributes to network transferable maps
  defp process_attributes(attributes) when is_map(attributes) do
    attributes
    |> Map.keys
    |> Enum.filter_map(
        fn (attr) -> attr in @reported_attributes end,
        fn (attr) -> attributes[attr] |> attribute_to_tuple end)
    |> Enum.into(%{})
  end

  defp process_attributes(attributes) when is_list(attributes) do
    attributes
    |> Enum.filter_map(
        fn (attr) -> attr in @reported_attributes end,
        &StructOps.to_underscore_name/1)
  end


  # Maps an attribute to a network-transferable tuple
  defp attribute_to_tuple(%Position{pos: pos} = attr),
  do: {attr |> StructOps.to_underscore_name, Map.from_struct(pos)}

  defp attribute_to_tuple(%Name{name: name} = attr),
  do: {attr |> StructOps.to_underscore_name, name}

  defp attribute_to_tuple(%Appearance{} = attr),
  do: {attr |> StructOps.to_underscore_name, Map.from_struct(attr)}

  defp attribute_to_tuple(%Health{health: health} = attr),
  do: {attr |> StructOps.to_underscore_name, health}

  defp attribute_to_tuple(%Energy{mana: mana} = attr),
  do: {attr |> StructOps.to_underscore_name, mana}
end
