defmodule Entice.Web.Discovery do
  @moduledoc """
  Discover entities with certain attributes, and let them know you're there!
  """
  alias Entice.Entity
  alias Entice.Web.Discovery


  # Outside API


  def init(entity_id, map) when is_atom(map) do
    if not (entity_id |> Entity.has_behaviour?(Discovery.Behaviour)),
    do: Entity.put_behaviour(entity_id, Discovery.Behaviour, %{map: map})
  end


  def notify_active(entity_id, topic, attribute_types),
  do: Entity.notify(entity_id, {:discovery_active, topic, attribute_types})


  def notify_inactive(entity_id, topic, attribute_types),
  do: Entity.notify(entity_id, {:discovery_inactive, topic, attribute_types})


  def remove(entity_id),
  do: Entity.remove_behaviour(entity_id, Discovery.Behaviour)


  # Behaviour internals


  defmodule Behaviour do
    use Entice.Entity.Behaviour
    use Entice.Logic.Attributes


    def init(id, attributes, %{map: map}) do
      Entice.Web.Endpoint.subscribe(self, "discovery:" <> map.underscore_name)
      {:ok, attributes, %{entity_id: id, map: map}}
    end


    def terminate(_reason, attributes, %{map: map}) do
      Entice.Web.Endpoint.unsubscribe(self, "discovery:" <> map.underscore_name)
      {:ok, attributes}
    end


    # setting your own status


    def handle_event({:discovery_active, topic, attribute_types}, attributes, %{entity_id: id, map: map} = state) do
      Entice.Web.Endpoint.entity_broadcast_from("discovery:" <> map.underscore_name, {
        :discovery_activated, id, topic, attribute_types, Map.take(attributes, attribute_types)})

      {:ok, attributes, state}
    end


    def handle_event({:discovery_inactive, topic, attribute_types}, attributes, %{entity_id: id, map: map} = state) do
      Entice.Web.Endpoint.entity_broadcast_from("discovery:" <> map.underscore_name, {
        :discovery_deactivated, id, topic, attribute_types})

      {:ok, attributes, state}
    end


    # react to broadcasts


    def handle_event({:discovery_activated, sender_id, topic, attribute_types, attrs}, attributes, %{entity_id: id,} = state) do
      if Enum.any?(attribute_types, fn t -> Map.has_key?(attributes, t) end) do
        Entice.Web.Endpoint.broadcast(topic, "discovered", %{
          recipient: id,
          entity_id: sender_id,
          attributes: attrs})

        Entice.Web.Endpoint.broadcast(topic, "discovered", %{
          recipient: sender_id,
          entity_id: id,
          attributes: Map.take(attributes, attribute_types)})
      end

      {:ok, attributes, state}
    end


    def handle_event({:discovery_deactivated, sender_id, topic, attribute_types}, attributes, %{entity_id: id} = state) do
      if Enum.any?(attribute_types, fn t -> Map.has_key?(attributes, t) end) do
        Entice.Web.Endpoint.broadcast(topic, "undiscovered", %{
          recipient: id,
          entity_id: sender_id})
      end

      {:ok, attributes, state}
    end
  end
end
