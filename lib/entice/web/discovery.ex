defmodule Entice.Web.Discovery do
  @moduledoc """
  Discover entities with certain attributes, and let them know you're there!
  """
  alias Entice.Entity
  alias Entice.Web.MapTopic
  alias Entice.Web.Discovery


  def register(entity_id) do
    if not (entity_id |> Entity.has_behaviour?(Discovery.Behaviour)),
    do: Entity.put_behaviour(entity_id, Discovery.Behaviour, [])
  end


  def unregister(entity_id),
  do: Entity.remove_behaviour(entity_id, Discovery.Behaviour)


  @doc """
  Request a reply from all entities that satisfy (have) the listed
  attribute types.
  Needs the sender's entity id and it's attributes.
  The recipients are required to reply (via the EntityTopic) with a

      {:discovered, %{entity_id: ..., attributes: ...}}

  (This will also be broadcastet on the EntityTopic of the entity
  that received the request)
  """
  def discovery_request(map, sender_id, attributes, attribute_types),
  do: MapTopic.broadcast_from(sender_id, map, {:discovery_request, sender_id, attributes, attribute_types})


  @doc """
  Notify entities in a map that the entity given by sender_id is
  leaving the map which they might want to propagate to their clients.
  """
  def undiscover_notify(map, sender_id, attributes),
  do: MapTopic.broadcast_from(sender_id, map, {:undiscover_notify, sender_id, attributes})


  defmodule Behaviour do
    use Entice.Entity.Behaviour
    use Entice.Logic.Attributes


    def handle_event(
        {:discovery_request, sender_id, sender_attributes, attribute_types},
        %Entity{id: id, attributes: attributes} = entity) do
      # notify me
      EntityTopic.broadcast(id, {:discovered, %{
        entity_id: sender_id,
        attributes: sender_attributes}})
      # reply if we satisfy the attribute requirements
      if attribute_types |> Enum.any?(&Map.has_key?(attributes, &1)) do
        EntityTopic.broadcast(sender_id, {:discovered, %{
          entity_id: id,
          attributes: Map.take(attributes, attribute_types)}})
      end
      {:ok, entity}
    end


    def handle_event(
        {:undiscover_notify, sender_id, sender_attributes},
        %Entity{id: id} = entity) do
      EntityTopic.broadcast(id, {:undiscovered, %{
        entity_id: sender_id,
        attributes: sender_attributes}})
      {:ok, entity}
    end
  end
end
