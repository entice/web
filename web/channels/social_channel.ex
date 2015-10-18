defmodule Entice.Web.SocialChannel do
  use Entice.Web.Web, :channel
  alias Entice.Logic.Area
  alias Entice.Logic.Group
  alias Phoenix.Socket


  def join("social:" <> map_rooms, _message, %Socket{assigns: %{map: map_mod}} = socket) do
    [map | rooms] = Regex.split(~r/:/, map_rooms)
    {:ok, ^map_mod} = Area.get_map(camelize(map))
    join_internal(rooms, socket)
  end


  # free for all mapwide channel
  defp join_internal([], socket), do: {:ok, socket}

  # group only channel, restricted to group usage
  defp join_internal(["group", leader_id], socket) do
    case Group.is_my_leader?(socket |> entity_id, leader_id) do
      false -> {:error, %{reason: "Access to this group chat denied"}}
      true  ->
        Coordination.register_observer(self)
        {:ok, socket |> set_leader(leader_id)}
    end
  end


  # Internal events


  @doc """
  Very simple check, might be triggering unecessarily... so if it gets too much
  we need to replace this with a more restrictive match, that checks if Leader or Member has
  been added/changed/updated
  """
  def handle_info({:entity_change, %{entity_id: leader_id}}, %Socket{assigns: %{leader: leader_id}} = socket) do
    case Group.is_my_leader?(socket |> entity_id, leader_id) do
      false -> {:stop, :group_leader_changed}
      true  -> {:noreply, socket}
    end
  end

  def handle_info({:entity_leave, %{entity_id: leader_id}}, %Socket{assigns: %{leader: leader_id}} = socket),
  do: {:stop, :group_leader_changed}

  def handle_info(_msg, socket), do: {:noreply, socket}


  # Incoming messages


  def handle_in("message", %{"text" => t}, socket) do
    broadcast(socket, "message", %{text: t, sender: socket |> name})
    {:noreply, socket}
  end


  def handle_in("emote", %{"action" => a}, socket) do
    broadcast(socket, "emote", %{action: a, sender: socket |> name})
    {:noreply, socket}
  end


  # internal


  def set_leader(socket, leader), do: socket |> assign(:leader, leader)
  def leader(socket),             do: socket.assigns[:leader]
end
