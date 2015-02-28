defmodule Entice.Web.Observer do
  @moduledoc """
  Report changes to certain attributes of an entity back to a certain topic.
  """
  alias Entice.Entity
  alias Entice.Web.Observer


  # Outside API


  def init(entity_id, topic, attribute_types) when is_bitstring(topic) do
    if not (entity_id |> Entity.has_behaviour?(Observer.Behaviour)),
    do: Entity.put_behaviour(entity_id, Observer.Behaviour, [])

    Entity.notify(entity_id, {:observer_enable, topic, attribute_types})
  end


  def deactivate(entity_id, topic),
  do: Entity.notify(entity_id, {:observer_disable, topic})


  def remove(entity_id),
  do: Entity.remove_behaviour(entity_id, Observer.Behaviour)


  # Behaviour internals


  defmodule Behaviour do
    use Entice.Entity.Behaviour
    use Entice.Logic.Attributes


    def init(id, attributes, _args), do: {:ok, attributes, %{entity_id: id, reporters: %{}}}


    def handle_event({:observer_enable, topic, attribute_types}, attributes, %{entity_id: id, reporters: reporters}) do
      reporters = reporters |> Map.put(topic, attribute_types)
      report(id, reporters, attributes)

      {:ok, attributes, %{entity_id: id, reporters: reporters}}
    end


    def handle_event({:observer_disable, topic}, attributes, %{entity_id: id, reporters: reporters}) do
      reporters = reporters |> Map.delete(topic)
      {:ok, attributes, %{entity_id: id, reporters: reporters}}
    end


    def handle_attributes_changed(_old, attributes, %{entity_id: id, reporters: reporters} = state) do
      report(id, reporters, attributes)
      {:ok, attributes, state}
    end


    # Internal


    defp report(entity_id, reporters, attributes) do
      for (topic <- reporters |> Map.keys) do
        if (reporters[topic] |> Enum.all?(fn attr -> attributes |> Map.has_key?(attr) end)) do
          reporters[topic]
          |> Enum.reduce(%{}, fn (attr, acc) -> acc |> Map.put(attr, attributes[attr]) end)
          |> (&(if not Enum.empty?(&1),
                do: Entice.Web.Endpoint.broadcast(topic, "observed", %{entity_id: entity_id, attributes: &1}))).()
        end
      end
    end
  end
end
