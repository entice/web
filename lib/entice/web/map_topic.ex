defmodule Entice.Web.MapTopic do
  @moduledoc """
  Register for events happening on map-level.
  """

  def subscribe(map_mod, pid \\ self) when is_atom(map_mod),
  do: Entice.Web.Endpoint.subscribe(pid, topic(map_mod))


  def unsubscribe(map_mod, pid \\ self) when is_atom(map_mod),
  do: Entice.Web.Endpoint.unsubscribe(pid, topic(map_mod))


  def broadcast(map_mod, message) when is_atom(map_mod),
  do: Entice.Web.Endpoint.entity_broadcast(topic(map_mod), message)


  def broadcast_from(map_mod, message) when is_atom(map_mod),
  do: broadcast_from(self, map_mod, message)

  def broadcast_from(pid, map_mod, message) when is_atom(map_mod),
  do: Entice.Web.Endpoint.entity_broadcast_from(pid, topic(map_mod), message)


  defp topic(map_mod), do: "internal:map:" <> map_mod.underscore_name
end
