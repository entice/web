defmodule Entice.Web.Player do
  @moduledoc """
  Responsible for the basic player stats, and propagates to anyone who
  cares to register if the player is leaving the map.
  """
  use Entice.Logic.Attributes
  alias Entice.Entity
  alias Entice.Web.Player
  import Entice.Utils.StructOps


  @doc """
  Prepares a single, simple player
  """
  def init(entity_id, map, char) do
    entity_id |> Entity.put_attribute(%Name{name: char.name})
    entity_id |> Entity.put_attribute(%Position{pos: map.spawn})
    entity_id |> Entity.put_attribute(copy_into(%Appearance{}, char))

    entity_id |> Entity.put_behaviour(Player.Behaviour, %{map: map})
  end


  def add_listener(entity_id, topic),
  do: Entity.notify(entity_id, {:player_add_listener, topic})


  def remove_listener(entity_id, topic),
  do: Entity.notify(entity_id, {:player_remove_listener, topic})


  def notify_mapchange(entity_id, new_entity_id, map),
  do: Entity.notify(entity_id, {:player_notify_mapchange, new_entity_id, map})


  def remove(entity_id) do
    entity_id |> Entity.remove_attribute(Name)
    entity_id |> Entity.remove_attribute(Position)
    entity_id |> Entity.remove_attribute(Appearance)

    entity_id |> Entity.remove_behaviour(Player.Behaviour)
  end


  def attributes(entity_id) do
    %{Name       => case entity_id |> Entity.fetch_attribute(Name) do {:ok, x} -> x end,
      Position   => case entity_id |> Entity.fetch_attribute(Position) do {:ok, x} -> x end,
      Appearance => case entity_id |> Entity.fetch_attribute(Appearance) do {:ok, x} -> x end}
  end


  defmodule Behaviour do
    use Entice.Entity.Behaviour

    def init(id, attributes, %{map: map}) do
      Entice.Web.Endpoint.subscribe(self, "player:" <> map.underscore_name)
      {:ok, attributes, %{entity_id: id, map: map, listeners: []}}
    end


    def handle_event({:player_add_listener, topic}, attributes, %{listeners: listeners} = state),
    do: {:ok, attributes, %{state | listeners: [topic | listeners]}}


    def handle_event({:player_remove_listener, topic}, attributes, %{listeners: listeners} = state),
    do: {:ok, attributes, %{state | listeners: [listeners] -- [topic]}}


    def handle_event({:player_notify_mapchange, new_entity_id, map}, attributes, %{entity_id: id, listeners: listeners} = state) do
      for topic <- listeners,
      do: Entice.Web.Endpoint.broadcast(topic, "mapchange", %{entity_id: id, new_entity_id: new_entity_id, map: map, attributes: attributes})
      {:ok, attributes, state}
    end


    def terminate(_reason, attributes, %{map: map}) do
      Entice.Web.Endpoint.unsubscribe(self, "player:" <> map.underscore_name)
      {:ok, attributes}
    end
  end
end
