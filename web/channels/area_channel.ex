defmodule Entice.Web.AreaChannel do
  use Phoenix.Channel
  use Entice.Area.Attributes
  alias Entice.Web.Clients
  alias Entice.Area
  alias Entice.Area.Entity
  import Phoenix.Naming
  import Entice.Web.Auth
  import Entice.Web.Utils


  def join("area:" <> map, %{"client_id" => client_id, "transfer_token" => token, "char_name" => name}, socket) do
    {:ok, ^token}  = Clients.get_transfer_token(client_id)
    {:ok, map_mod} = Area.get_map(camelize(map))
    {:ok, char}    = Clients.get_char(client_id, name)
    Clients.delete_transfer_token(client_id)

    {:ok, entity_id} = prepare_player(map_mod, char)

    socket = socket
      |> set_area(map_mod)
      |> set_entity_id(entity_id)
      |> set_client_id(client_id)

    socket |> reply("join:ok", %{entity: entity_id, entities: Entity.get_entity_dump(map_mod)})
    {:ok, socket}
  end


  def handle_in("entity:move", %{"pos" => %{"x" => x, "y" => y}}, socket) do
    Entity.put_attribute(socket |> area, socket |> entity_id,
      %Position{pos: %Coord{x: x, y: y}})
    {:ok, socket}
  end


  def handle_out("entity:add", %{entity_id: id} = msg, socket) do
    if (id == socket |> entity_id), do: socket |> reply("entity:add", msg)
    {:ok, socket}
  end


  def handle_out(event, message, socket) do
    reply(socket, event, message)
    {:ok, socket}
  end


  def leave(_msg, socket) do
    Entity.stop(socket |> area, socket |> entity_id)
    {:ok, socket}
  end

  # Internal

  defp prepare_player(map, char) do
    Entity.start(map, UUID.uuid4(), %{
      Name => %Name{name: char.name},
      Position => %Position{pos: map.spawn},
      Appearance => copy_into(%Appearance{}, char)})
  end

  defp set_area(socket, area), do: socket |> assign(:area, area)
  defp area(socket),           do: socket.assigns[:area]

  defp set_entity_id(socket, entity_id), do: socket |> assign(:entity_id, entity_id)
  defp entity_id(socket),                do: socket.assigns[:entity_id]

  defp set_client_id(socket, client_id), do: socket |> assign(:client_id, client_id)
  defp client_id(socket),                do: socket.assigns[:client_id]
end
