defmodule Entice.Web.GroupChannel do
  use Entice.Web.Web, :channel
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Logic.Area
  alias Entice.Logic.Group
  alias Entice.Entity
  alias Entice.Entity.Coordination
  alias Entice.Web.Token
  alias Entice.Web.Endpoint
  alias Phoenix.Socket
  import Phoenix.Naming


  @reported_attributes [
    Leader,
    Member]


  def join("group:" <> map, _message, %Socket{assigns: %{map: map_mod}} = socket) do
    {:ok, ^map_mod} = Area.get_map(camelize(map))
    Process.flag(:trap_exit, true)
    send(self, :after_join)
    {:ok, socket}
  end


  def handle_info(:after_join, socket) do
    Coordination.register_observer(self)
    :ok = Group.register(socket |> entity_id)
    socket |> push("join:ok", %{})
    {:noreply, socket}
  end


  # Internal events


  def handle_info({:entity_join, %{entity_id: entity_id, attributes: %{Leader => leader}}}, socket) do
    socket |> push_update(entity_id, leader)
    {:noreply, socket}
  end

  def handle_info({:entity_change, %{entity_id: entity_id, added: %{Leader => leader}}}, socket) do
    socket |> push_update(entity_id, leader)
    {:noreply, socket}
  end

  def handle_info({:entity_change, %{entity_id: entity_id, changed: %{Leader => leader}}}, socket) do
    socket |> push_update(entity_id, leader)
    {:noreply, socket}
  end

  def handle_info({:entity_leave, %{entity_id: entity_id, attributes: %{Leader => _}}}, socket) do
    socket |> push("remove", %{entity: entity_id})
    {:noreply, socket}
  end


  def handle_info({:entity_mapchange, %{map: map_mod}}, socket) do
    mems =
      case Entity.fetch_attribute(socket |> entity_id, Leader) do
        {:ok, %Leader{members: mems}} -> mems
        _                             -> []
      end

    mems |> Enum.map(
      fn member ->
        Endpoint.plain_broadcast(
          Entice.Web.Socket.id_by_entity(member),
          {:leader_mapchange, %{map: map_mod}})
      end)

    {:noreply, socket}
  end


  def handle_info({:leader_mapchange, %{map: map_mod}}, socket) do
    {:ok, _token} = Token.create_mapchange_token(socket |> client_id, %{
      entity_id: socket |> entity_id,
      map: map_mod,
      char: socket |> character})

    # TODO pls check if some this needs to be replaced?
    #Observer.notify_mapchange(socket |> entity_id, map_mod)

    socket |> push("map:change", %{map: map_mod.underscore_name})

    {:noreply, socket}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}


  # Incoming events


  def handle_in("merge", %{"target" => id}, socket) do
    Group.invite(socket |> entity_id, id)
    {:noreply, socket}
  end


  def handle_in("kick", %{"target" => id}, socket) do
    Group.kick(socket |> entity_id, id)
    {:noreply, socket}
  end


  # Leaving the socket (voluntarily or forcefully)


  def terminate(_msg, socket) do
    Group.unregister(socket |> entity_id)
    :ok
  end


  # Internal


  defp push_update(socket, entity_id, leader) do
    socket |> push("update", %{
      leader: entity_id,
      members: leader.members,
      invited: leader.invited})
  end
end
