defmodule Entice.Web.Dump do
  @moduledoc """
  If we spawn entities, we want the other entities in the area to
  propagate their state to this new entity.
  """
  use Entice.Logic.Attributes
  alias Entice.Entity
  alias Entice.Web.Dump


  def init(entity_id, area) when is_atom(area),
  do: Entity.put_behaviour(entity_id, Dump.Behaviour, %{area: area})


  def remove(entity_id),
  do: Entity.remove_behaviour(entity_id, Dump.Behaviour)


  def notify_added(entity_id, area),
  do: Entice.Web.Endpoint.broadcast("dump:" <> area.underscore_name, {:added, entity_id})


  defmodule Behaviour do
    use Entice.Entity.Behaviour


    def init(id, attributes, %{area: area}) do
      Entice.Web.Endpoint.subscribe(self, "dump:" <> area.underscore_name)
      {:ok, attributes, %{entity_id: id, area: area}}
    end


    def handle_event(
        {:added, sender_id},
        %{Name => n, Position => p, Appearance => a} = attributes,
        %{entity_id: id, area: area} = state) do

      Entice.Web.Endpoint.broadcast("dump:" <> area.underscore_name, "entity_dump", %{
        new: sender_id,
        existing: id,
        attributes: %{Name => n, Position => p, Appearance => a}})

      {:ok, attributes, state}
    end


    def terminate(_reason, attributes, %{area: area}) do
      Entice.Web.Endpoint.unsubscribe(self, "dump:" <> area.underscore_name)
      {:ok, attributes}
    end
  end
end
