defmodule Entice.Web.EntityTopic do
  @moduledoc """
  Register for events emitted by or concerning a certain entity.
  """


  def subscribe(entity_id, pid \\ self) when not is_pid(entity_id),
  do: Entice.Web.Endpoint.subscribe(pid, topic(entity_id))


  def unsubscribe(entity_id, pid \\ self) when not is_pid(entity_id),
  do: Entice.Web.Endpoint.unsubscribe(pid, topic(entity_id))


  def broadcast(entity_id, message) when not is_pid(entity_id),
  do: Entice.Web.Endpoint.entity_broadcast(topic(entity_id), message)


  def broadcast_from(entity_id, message) when is_atom(entity_id),
  do: broadcast_from(self, entity_id, message)

  def broadcast_from(pid, entity_id, message) when is_atom(entity_id),
  do: Entice.Web.Endpoint.entity_broadcast_from(pid, topic(entity_id), message)


  def broadcast_mapchange(entity_id, map),
  do: broadcast_from(entity_id, {:mapchange, %{entity_id: entity_id, map: map}})


  defp topic(entity_id), do: "internal:entity:" <> to_string(entity_id)
end
