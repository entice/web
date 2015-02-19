defmodule Entice.Web.EntityChannel do
  use Phoenix.Channel
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Web.Client
  alias Entice.Web.Token
  alias Entice.Web.Player
  alias Entice.Web.EntityChannel
  import Phoenix.Naming
  import Entice.Web.ChannelHelper


  @chan "entity:"


  # Initializing the connection


  def join(@chan <> map, %{"client_id" => client_id, "entity_token" => token}, socket) do
    {:ok, ^token, :entity, %{entity_id: entity_id, area: map_mod, char: char}} = Token.get_token(client_id)
    {:ok, ^map_mod} = Area.get_map(camelize(map))

    # fetch a dump of the state of other entities
    :ok = EntityChannel.Behaviour.init(entity_id, map_mod)

    socket = socket
      |> set_area(map_mod)
      |> set_entity_id(entity_id)
      |> set_client_id(client_id)
      |> set_character(char)

    socket |> reply("join:ok", %{})
    {:ok, socket}
  end


  # Outgoing Event API


  def handle_out("entity_added", %{added: entity_id, attributes: attributes}, socket) do
    if (entity_id != socket |> entity_id),
    do: socket |> reply("add", %{entity_id: entity_id, attributes: attributes})
    {:ok, socket}
  end


  def handle_out("entity_dump", %{new: new_entity_id, existing: entity_id, attributes: attributes}, socket) do
    if (new_entity_id == socket |> entity_id),
    do: socket |> reply("add", %{entity_id: entity_id, attributes: attributes})
    {:ok, socket}
  end


  def handle_out("entity_removed", %{removed: entity_id}, socket) do
    if (entity_id != socket |> entity_id),
    do: socket |> reply("remove", %{entity_id: entity_id})
    {:ok, socket}
  end


  def handle_out(_event, _message, socket), do: {:ok, socket}


  # Socket leave


  def leave(_msg, socket) do
    EntityChannel.Behaviour.remove(socket |> entity_id)
    {:ok, socket}
  end
end


defmodule Entice.Web.EntityChannel.Behaviour do
  use Entice.Entity.Behaviour
  use Entice.Logic.Attributes
  alias Entice.Entity
  alias Entice.Web.EntityChannel

  @chan "entity:"
  @internal "dump:"


  # Outside API


  def init(entity_id, area) when is_atom(area),
  do: Entity.put_behaviour(entity_id, EntityChannel.Behaviour, %{area: area})


  def remove(entity_id),
  do: Entity.remove_behaviour(entity_id, EntityChannel.Behaviour)


  # Behaviour internals


  def init(id, %{Name => n, Position => p, Appearance => a} = attributes, %{area: area}) do
    Entice.Web.Endpoint.subscribe(self, @internal <> area.underscore_name)

    # send to entities
    Entice.Web.Endpoint.entity_broadcast_from(@internal <> area.underscore_name, {:added, id})
    # send to sockets
    Entice.Web.Endpoint.broadcast(@chan <> area.underscore_name, "entity_added", %{
      added: id,
      attributes: %{Name => n, Position => p, Appearance => a}})

    {:ok, attributes, %{entity_id: id, area: area}}
  end


  def handle_event(
      {:added, sender_id},
      %{Name => n, Position => p, Appearance => a} = attributes,
      %{entity_id: id, area: area} = state) do

    Entice.Web.Endpoint.broadcast(@chan <> area.underscore_name, "entity_dump", %{
      new: sender_id,
      existing: id,
      attributes: %{Name => n, Position => p, Appearance => a}})

    {:ok, attributes, state}
  end


  def terminate(_reason, attributes, %{entity_id: id, area: area}) do
    Entice.Web.Endpoint.unsubscribe(self, @internal <> area.underscore_name)
    Entice.Web.Endpoint.broadcast(@chan <> area.underscore_name, "entity_removed", %{removed: id})
    {:ok, attributes}
  end
end
