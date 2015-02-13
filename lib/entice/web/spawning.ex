defmodule Entice.Web.Spawning do
  @moduledoc """
  If we spawn entities, we want the other entities in the area to
  propagate their state to this new entity.
  """
  alias Entice.Entity
  alias Phoenix.PubSub
  alias Phoenix.Channel
  alias Entice.Web.Spawning.SpawnBehaviour

  @bus Entice.Web.PubSub


  def init(entity_id, area) when is_atom(area),
  do: Entity.put_behaviour(entity_id, SpawnBehaviour, %{area: area})


  def remove(entity_id),
  do: Entity.remove_behaviour(entity_id, SpawnBehaviour)


  def notfiy_spawned(entity_id, area),
  do: PubSub.publish(@bus, "spawning:" <> area.underscore_name, {:spawn, entity_id})


  defmodule SpawnBehaviour do
    use Entice.Entity.Behaviour


    def init(id, attributes, %{area: area}) do
      PubSub.subscribe(@bus, self, "spawning:" <> area.underscore_name)
      {:ok, attributes, %{entity_id: id, area: area}}
    end


    def handle_event({:spawn, sender_id}, attributes, %{entity_id: id, area: area} = state) do
      Channel.publish(@bus, "spawning:" <> area.underscore_name, "report_existing", %{new: sender_id, existing: id, attributes: attributes})
      {:ok, attributes, state}
    end


    def terminate(_reason, attributes, %{area: area} = state),
    do: PubSub.unsubscribe(@bus, self, "spawning:" <> area.underscore_name)
  end
end
