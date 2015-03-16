defmodule Entice.Web.Discovery do
  @moduledoc """
  Discover entities with certain attributes, and let them know you're there!
  """
  alias Entice.Entity
  alias Entice.Web.Discovery


  # Outside API


  def register(entity_id, map) when is_atom(map) do
    if not (entity_id |> Entity.has_behaviour?(Discovery.Behaviour)),
    do: Entity.put_behaviour(entity_id, Discovery.Behaviour, %{map: map})
  end


  def unregister(entity_id),
  do: Entity.remove_behaviour(entity_id, Discovery.Behaviour)


  def notify_active(entity_id, topic, attribute_types),
  do: Entity.notify(entity_id, {:discovery_active, topic, attribute_types})


  def notify_inactive(entity_id, topic, attribute_types),
  do: Entity.notify(entity_id, {:discovery_inactive, topic, attribute_types})


  defmodule Behaviour do
    use Entice.Entity.Behaviour
    use Entice.Logic.Attributes


    def init(%Entity{attributes: %{MapInstance => %MapInstance{map: map}}} = entity, _args) do
      Entice.Web.Endpoint.subscribe(self, "discovery:" <> map.underscore_name)
      {:ok, entity}
    end


    # setting your own status


    def handle_event({:discovery_active, topic, attribute_types}, %Entity{id: id, attributes: %{MapInstance => %MapInstance{map: map}}} = entity) do
      Entice.Web.Endpoint.entity_broadcast_from("discovery:" <> map.underscore_name, {
        :discovery_activated, id, topic, attribute_types, Map.take(entity.attributes, attribute_types)})
      {:ok, entity}
    end


    def handle_event({:discovery_inactive, topic, attribute_types}, %Entity{id: id, attributes: %{MapInstance => %MapInstance{map: map}}} = entity) do
      Entice.Web.Endpoint.entity_broadcast_from("discovery:" <> map.underscore_name, {
        :discovery_deactivated, id, topic, attribute_types})
      {:ok, entity}
    end


    # react to broadcasts


    def handle_event(
        {:discovery_activated, sender_id, topic, attribute_types, attrs},
        %Entity{id: id, attributes: attributes} = entity) do

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

      {:ok, entity}
    end


    def handle_event(
        {:discovery_deactivated, sender_id, topic, attribute_types},
        %Entity{id: id, attributes: attributes} = entity) do

      if Enum.any?(attribute_types, fn t -> Map.has_key?(attributes, t) end) do
        Entice.Web.Endpoint.broadcast(topic, "undiscovered", %{
          recipient: id,
          entity_id: sender_id})
      end

      {:ok, entity}
    end


    def terminate(_reason, %Entity{attributes: %{MapInstance => %MapInstance{map: map}}} = entity) do
      Entice.Web.Endpoint.unsubscribe(self, "discovery:" <> map.underscore_name)
      {:ok, entity}
    end
  end
end
