defmodule Entice.Web.VitalityChannel do
  use Phoenix.Channel
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Entity
  alias Entice.Logic.Area
  alias Entice.Web.Token
  alias Entice.Web.Observer
  import Phoenix.Naming
  import Entice.Web.ChannelHelper


  def join("vitality:" <> map, %{"client_id" => client_id, "entity_token" => token}, socket) do
    {:ok, ^token, :entity, %{map: map_mod, entity_id: entity_id, char: char}} = Token.get_token(client_id)
    {:ok, ^map_mod} = Area.get_map(camelize(map))

    Observer.register(entity_id)
    Observer.notify_active(entity_id, "vitality:" <> map, [VitalStats])

    socket = socket
      |> set_map(map_mod)
      |> set_entity_id(entity_id)
      |> set_client_id(client_id)
      |> set_character(char)

    socket |> reply("join:ok", %{})
    {:ok, socket}
  end


  def handle_out("observed", %{entity_id: entity_id, attributes: %{VitalStats => vitals}}, socket) do
    socket |> reply("update", %{
      vitality: Map.from_struct(vitals)})
    {:ok, socket}
  end


  def handle_out("update:" <> value, %{} = msg, socket)
  when value in ["pos", "goal", "movetype"] do
    socket |> reply("update:" <> value, msg)
    {:ok, socket}
  end


  def handle_out("terminated", %{entity_id: entity_id}, socket) do
    case (entity_id == socket |> entity_id) do
      true  -> {:leave, socket}
      false -> {:ok, socket}
    end
  end


  def handle_out(_event, _message, socket), do: {:ok, socket}


  def leave(_msg, socket) do
    Observer.notify_inactive(socket |> entity_id, socket.topic)
    Move.unregister(socket |> entity_id)
    {:ok, socket}
  end
end

