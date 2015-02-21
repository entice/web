defmodule Entice.Web.GroupChannel do
  use Phoenix.Channel
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Entity
  alias Entice.Logic.Area
  alias Entice.Logic.Group
  alias Entice.Web.Token
  alias Entice.Web.GroupChannel.AttributeObserver
  import Phoenix.Naming
  import Entice.Web.ChannelHelper


  def join("group:" <> map, %{"client_id" => client_id, "entity_token" => token}, socket) do
    {:ok, ^token, :entity, %{area: map_mod, entity_id: entity_id, char: char}} = Token.get_token(client_id)
    {:ok, ^map_mod} = Area.get_map(camelize(map))

    :ok = Entity.put_behaviour(entity_id, AttributeObserver, %{area: map_mod})
    :ok = Group.init(entity_id)

    socket = socket
      |> set_area(map_mod)
      |> set_entity_id(entity_id)
      |> set_client_id(client_id)
      |> set_character(char)

    socket |> reply("join:ok", %{})
    {:ok, socket}
  end


  def handle_in("merge", %{"target" => id}, socket) do
    Group.merge(socket |> entity_id, id)
    {:ok, socket}
  end


  def handle_in("kick", %{"target" => id}, socket) do
    Group.kick(socket |> entity_id, id)
    {:ok, socket}
  end


  def handle_out("leader_changed", %{entity_id: id, new: %Leader{members: mems, invited: invs}}, socket) do
    socket |> reply("group:change", %{leader: id, members: mems, invited: invs})
    {:ok, socket}
  end


  def leave(_msg, socket) do
    Group.remove(socket |> entity_id)
    Entity.remove_behaviour(socket |> entity_id, AttributeObserver)
    {:ok, socket}
  end


  defmodule AttributeObserver do
    use Entice.Entity.Behaviour

    def init(id, attributes, %{area: area}), do: {:ok, attributes, %{entity_id: id, area: area}}

    def handle_attributes_changed(%{Leader => _old}, %{Leader => new_lead} = attributes,  %{entity_id: id, area: area} = state) do
      Entice.Web.Endpoint.broadcast(
        "group:" <> area.underscore_name,
        "leader_changed", %{entity_id: id, new: new_lead})
      {:ok, attributes, state}
    end
  end
end
