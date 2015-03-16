defmodule Entice.Web.Observer do
  @moduledoc """
  Report changes to certain attributes of an entity back to a certain topic.

  If the attributes you subscribed for changed, you will receive:

      {:socket_broadcast, topic: "your:topic", event: "observed", payload: %{entity_id: "your-entity-id", attributes: %{...}}}

  If an attribute you subscribed for got removed, you will receive:

      {:socket_broadcast, topic: "your:topic", event: "missed", payload: %{entity_id: "your-entity-id", attributes: [YourMissedAttribute1, YourMissedAttribute2]}}

  If the entity terminates you will receive:

      {:socket_broadcast, topic: "your:topic", event: "terminated", payload: %{entity_id: "your-entity-id", attributes: %{...}}}
  """
  use Entice.Logic.Attributes
  alias Entice.Entity
  alias Entice.Web.Observer


  defstruct observers: %{}


  # External API


  def register(entity_id) do
    if not (entity_id |> Entity.has_behaviour?(Observer.Behaviour)),
    do: Entity.put_behaviour(entity_id, Observer.Behaviour, [])
  end


  def unregister(entity_id),
  do: Entity.remove_behaviour(entity_id, Observer.Behaviour)


  def notify_active(entity_id, topic, attribute_types),
  do: Entity.notify(entity_id, {:observer_active, topic, attribute_types})


  def notify_inactive(entity_id, topic),
  do: Entity.notify(entity_id, {:observer_inactive, topic})


  def notify_mapchange(entity_id, map),
  do: Entity.notify(entity_id, {:observer_mapchange, map})


  defmodule Behaviour do
    use Entice.Entity.Behaviour
    use Entice.Logic.Attributes


    def init(%Entity{attributes: %{MapInstance => %MapInstance{map: map}}} = entity, _args) do
      Entice.Web.Endpoint.subscribe(self, "observer:" <> map.underscore_name)
      {:ok, entity |> put_attribute(%Observer{})}
    end


    def handle_event({:observer_active, topic, attribute_types}, %Entity{id: id, attributes: %{Observer => %Observer{observers: observers}}} = entity) do
      new_observers = observers |> Map.put(topic, attribute_types)
      report(id, new_observers, %{}, entity.attributes)
      {:ok, entity |> put_attribute(%Observer{observers: new_observers})}
    end


    def handle_event({:observer_inactive, topic}, %Entity{attributes: %{Observer => %Observer{observers: observers}}} = entity) do
      new_observers = observers |> Map.delete(topic)
      {:ok, entity |> put_attribute(%Observer{observers: new_observers})}
    end


    def handle_event({:observer_mapchange, map}, %Entity{id: id, attributes: %{Observer => %Observer{observers: observers}}} = entity) do
      report_mapchange(id, observers, map, entity.attributes)
      {:ok, entity}
    end


    def handle_change(old, %Entity{id: id, attributes: %{Observer => %Observer{observers: observers}}} = entity) do
      report(id, observers, old.attributes, entity.attributes)
      report_missing(id, observers, old.attributes, entity.attributes)
      {:ok, entity}
    end


    def terminate(:shutdown, %Entity{id: id, attributes: %{
        MapInstance => %MapInstance{map: map},
        Observer => %Observer{observers: observers}}} = entity) do
      report(id, observers, %{}, entity.attributes, "terminated")
      Entice.Web.Endpoint.unsubscribe(self, "observer:" <> map.underscore_name)
      {:ok, entity}
    end

    def terminate(_reason, %Entity{attributes: %{MapInstance => %MapInstance{map: map}}} = entity) do
      Entice.Web.Endpoint.unsubscribe(self, "observer:" <> map.underscore_name)
      {:ok, entity}
    end


    # Internal


    defp report(entity_id, observers, old, attributes, message \\ "observed") do
      for (topic <- observers |> Map.keys),
      do: report_internal(entity_id, topic, observers[topic], old, attributes, message)
    end

    defp report_internal(entity_id, topic, [], _old, _attributes, message),
    do: Entice.Web.Endpoint.broadcast(topic, message, %{entity_id: entity_id, attributes: %{}})

    defp report_internal(entity_id, topic, reported_attributes, old, attributes, message) do
      # report only if all requested attrs are available and any of them changed
      if (reported_attributes |> Enum.all?(fn attr -> attributes |> Map.has_key?(attr) end)) and
         (reported_attributes |> Enum.any?(fn attr -> attributes |> Map.get(attr) != (old |> Map.get(attr)) end)) do
        reported_attributes
        |> Enum.reduce(%{}, fn (attr, acc) -> acc |> Map.put(attr, attributes[attr]) end)
        |> (&(if not Enum.empty?(&1),
              do: Entice.Web.Endpoint.broadcast(topic, message, %{entity_id: entity_id, attributes: &1}))).()
      end
    end


    defp report_missing(entity_id, observers, attrs_before, attrs_after) do
      for (topic <- observers |> Map.keys) do
        observers[topic]
        |> Enum.filter(fn attr -> (attrs_before |> Map.has_key?(attr)) and not (attrs_after |> Map.has_key?(attr)) end)
        |> (&(if not Enum.empty?(&1),
              do: Entice.Web.Endpoint.broadcast(topic, "missed", %{entity_id: entity_id, attributes: &1}))).()
      end
    end


    defp report_mapchange(entity_id, observers, map, attributes) do
      for (topic <-  observers |> Map.keys),
      do: Entice.Web.Endpoint.broadcast(topic, "mapchange", %{entity_id: entity_id, map: map, attributes: attributes})
    end
  end
end
