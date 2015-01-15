defmodule Entice.Web.AreaEventBridge do
  use GenEvent

  def handle_event({:entity_added, area, id, attrs}, state) do
    Phoenix.Channel.broadcast("area:" <> area.underscore_name,
      "entity:add",
      %{entity_id: id, attributes: attrs})
    {:ok, state}
  end

  def handle_event({:entity_removed, area, id}, state) do
    Phoenix.Channel.broadcast("area:" <> area.underscore_name,
      "entity:remove",
      %{entity_id: id})
    {:ok, state}
  end

  def handle_event({:attribute_updated, area, id, attr}, state) do
    Phoenix.Channel.broadcast("area:" <> area.underscore_name,
      "entity:attribute:update",
      %{entity_id: id, attribute: attr})
    {:ok, state}
  end

  def handle_event({:attribute_removed, area, id, attr}, state) do
    Phoenix.Channel.broadcast("area:" <> area.underscore_name,
      "entity:attribute:remove",
      %{entity_id: id, attribute_type: attr})
    {:ok, state}
  end
end
