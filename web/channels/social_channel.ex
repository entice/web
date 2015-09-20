defmodule Entice.Web.SocialChannel do
  use Entice.Web.Web, :channel
  use Entice.Logic.Area
  alias Entice.Logic.Group
  alias Entice.Web.Token
  alias Phoenix.Socket
  import Phoenix.Naming


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
      true  -> {:ok, socket}
      false -> {:error, "Access to this group chat denied"}
    end
  end


  # Incoming messages


  def handle_in("message", %{"text" => t}, socket) do
    broadcast(socket, "message", %{text: t, sender: socket |> name})
    {:noreply, socket}
  end


  def handle_in("emote", %{"action" => a}, socket) do
    broadcast(socket, "emote", %{action: a, sender: socket |> name})
    {:noreply, socket}
  end
end
