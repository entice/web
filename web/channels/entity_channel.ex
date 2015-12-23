defmodule Entice.Web.EntityChannel do
  use Entice.Web.Web, :channel
  use Entice.Logic.Attributes
  alias Entice.Utils.StructOps
  alias Entice.Entity
  alias Entice.Entity.Coordination
  alias Entice.Logic.Maps
  alias Entice.Logic.Npc
  alias Entice.Web.Endpoint
  alias Entice.Web.Token
  alias Phoenix.Socket

  @all_reported_attributes [
    Position,
    Name,
    Appearance,
    Health,
    Energy,
    Morale,
    Level,
    Npc]

  @initally_reported_attributes [
    Position]

  @continually_reported_attributes @all_reported_attributes -- @initally_reported_attributes


  def join("entity:" <> map, _message, %Socket{assigns: %{map: map_mod}} = socket) do
    {:ok, ^map_mod} = Maps.get_map(camelize(map))
    Process.flag(:trap_exit, true)
    send(self, :after_join)
    {:ok, socket}
  end


  def handle_info(:after_join, socket) do
    Coordination.register_observer(self, socket |> map)
    attrs = socket |> entity_id |> Entity.take_attributes(@all_reported_attributes)
    socket |> push("initial", %{attributes: process_attributes(attrs, @all_reported_attributes)})
    {:noreply, socket}
  end


  # Internal events


  @doc "If this entity leaves, disconnect all sockets, and shut this down as well"
  def handle_info({:entity_leave, %{entity_id: eid}}, %Socket{assigns: %{entity_id: eid}} = socket) do
    Endpoint.broadcast(Entice.Web.Socket.id(socket), "disconnect", %{})
    {:stop, :normal, socket}
  end


  @doc "Filter out 'join' messages of this entity, which we'd get after registering as an observer"
  def handle_info({:entity_join, %{entity_id: eid}}, %Socket{assigns: %{entity_id: eid}} = socket), do: {:noreply, socket}


  def handle_info({:entity_join, %{entity_id: entity_id, attributes: attrs}}, socket) do
    res = process_attributes(attrs, @all_reported_attributes)
    if not Enum.empty?(res) do
      socket |> push("add", %{
        entity: entity_id,
        attributes: res})
    end
    {:noreply, socket}
  end


  def handle_info({:entity_leave, %{entity_id: entity_id, attributes: _attrs}}, socket) do
    socket |> push("remove", %{entity: entity_id})
    {:noreply, socket}
  end


  def handle_info({:entity_change, %{
      entity_id: id,
      added: added,
      changed: changed,
      removed: removed}}, socket) do
    res = [
      process_attributes(added, @all_reported_attributes),
      process_attributes(changed, @continually_reported_attributes),
      process_attributes(removed, @all_reported_attributes)]
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
    reply = case Maps.get_map(camelize(map)) do
      {:ok, map_mod} ->
        {:ok, _token}  = Token.create_mapchange_token(socket |> client_id, %{
          entity_id: socket |> entity_id,
          map: map_mod,
          char: socket |> character})

        Endpoint.plain_broadcast(Entice.Web.Socket.id(socket), {:entity_mapchange, %{map: map_mod}})
        {:ok, %{map: map}}

      _ -> {:error, %{reason: :unknown_map}}
    end

    {:reply, reply, socket}
  end


  # Leaving the socket (voluntarily or forcefully)


  def terminate(_msg, socket) do
    Entity.stop(socket |> entity_id)
    :ok
  end


  # Internal


  # Transform attributes to network transferable maps
  defp process_attributes(attributes, filter) when is_map(attributes) do
    attributes
    |> Map.keys
    |> Enum.filter_map(
        fn (attr) -> attr in filter end,
        fn (attr) -> attributes[attr] |> attribute_to_tuple end)
    |> Enum.into(%{})
  end

  defp process_attributes(attributes, filter) when is_list(attributes) do
    attributes
    |> Enum.filter_map(
        fn (attr) -> attr in filter end,
        &StructOps.to_underscore_name/1)
  end


  # Maps an attribute to a network-transferable tuple
  defp attribute_to_tuple(%Position{pos: pos, plane: plane} = attr),
  do: {attr |> StructOps.to_underscore_name, Map.from_struct(pos) |> Map.put(:plane, plane)}

  defp attribute_to_tuple(%Name{name: name} = attr),
  do: {attr |> StructOps.to_underscore_name, name}

  defp attribute_to_tuple(%Appearance{} = attr),
  do: {attr |> StructOps.to_underscore_name, Map.from_struct(attr)}

  defp attribute_to_tuple(%Health{} = attr),
  do: {attr |> StructOps.to_underscore_name, Map.from_struct(attr)}

  defp attribute_to_tuple(%Energy{} = attr),
  do: {attr |> StructOps.to_underscore_name, Map.from_struct(attr)}

  defp attribute_to_tuple(%Morale{morale: morale} = attr),
  do: {attr |> StructOps.to_underscore_name, morale}

  defp attribute_to_tuple(%Level{level: lvl} = attr),
  do: {attr |> StructOps.to_underscore_name, lvl}

  defp attribute_to_tuple(%Npc{npc_model_id: npc_model_id} = attr),
  do: {attr |> StructOps.to_underscore_name, npc_model_id}
end
