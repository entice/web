defmodule Entice.Web.SocialChannel do
  use Entice.Web.Web, :channel
  use Entice.Logic.Area
  alias Entice.Logic.Group
  alias Entice.Web.Token
  alias Entice.Web.Observer
  import Phoenix.Naming


  def join("social:" <> map_rooms, %{"client_id" => id, "entity_token" => token}, socket) do
    [map | rooms] = Regex.split(~r/:/, map_rooms)
    {:ok, ^token, :entity, %{map: map_mod, entity_id: entity_id, char: char}} = Token.get_token(id)
    {:ok, ^map_mod} = Area.get_map(camelize(map))

    socket = socket
      |> set_map(map_mod)
      |> set_entity_id(entity_id)
      |> set_client_id(id)
      |> set_name(char.name)
      |> set_character(char)

    join_internal(entity_id, rooms, "social:" <> map_rooms, socket)
  end


  # free for all mapwide channel
  defp join_internal(entity_id, [], topic, socket) do
    Observer.register(entity_id)
    Observer.notify_active(entity_id, topic, [])

    socket |> push("join:ok", %{})
    {:ok, socket}
  end


  # group only channel, restricted to group usage
  defp join_internal(entity_id, ["group", leader_id], topic, socket) do
    case Group.is_my_leader?(entity_id, leader_id) do
      false ->
        socket |> push("join:error", %{})
        :ignore
      true ->
        Observer.register(entity_id)
        Observer.notify_active(entity_id, topic, [])

        socket |> push("join:ok", %{})
        {:ok, socket}
    end
  end


  # Incoming messages


  def handle_in("message", %{"text" => t}, socket) do
    broadcast(socket, "message", %{text: t, sender: socket |> name})
  end


  def handle_in("emote", %{"action" => a}, socket) do
    broadcast(socket, "emote", %{action: a, sender: socket |> name})
  end


  # Outgoing messages


  def handle_out("terminated", %{entity_id: entity_id}, socket) do
    case (entity_id == socket |> entity_id) do
      true  -> {:leave, socket}
      false -> {:ok, socket}
    end
  end


  def handle_out(_event, _message, socket), do: {:ok, socket}


  def leave(_msg, socket) do
    Observer.notify_inactive(socket |> entity_id, socket.topic)
    {:ok, socket}
  end
end
