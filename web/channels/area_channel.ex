defmodule Entice.Web.AreaChannel do
  use Phoenix.Channel
  use Entice.Area.Attributes
  alias Entice.Area
  alias Entice.Area.Entity
  import Phoenix.Naming


  def join("area:" <> map, _handshake_msg, socket) do
    join_internal(map |> camelize |> Area.get_map, socket)
  end

  defp join_internal({:error, _}, socket), do: {:error, socket, :unauthorized}
  defp join_internal({:ok, map}, socket) do
    {:ok, id} = prepare_player(map)

    socket = socket
      |> set_area(map)
      |> set_entity_id(id)
      |> subscribe("area:" <> map.underscore_name)

    socket |> reply("join:ok", %{entity: id, entities: Entity.get_entity_dump(map)})
    {:ok, socket}
  end


  def handle_in("entity:move", %{"pos" => %{"x" => x, "y" => y}}, socket) do
    Entity.put_attribute(socket |> area, socket |> entity_id,
      %Position{pos: %Coord{x: x, y: y}})
    socket
  end


  def handle_out("entity:add", %{entity_id: id} = msg, socket) do
    if (id == socket |> entity_id) do
      socket
    else
      socket |> reply("entity:add", msg)
    end
  end


  def handle_out(event, message, socket) do
    reply(socket, event, message)
    socket
  end


  def leave(_msg, socket) do
    Entity.stop(socket |> area, socket |> entity_id)
    socket
  end


  defp prepare_player(map) do
    Entity.start(map, UUID.uuid4(), %{
      Name => %Name{name: "Test Char"},
      Position => %Position{pos: map.spawn}})
  end

  defp set_area(socket, area), do: socket |> assign(:area, area)
  defp area(socket),           do: socket.assigns[:area]

  defp set_entity_id(socket, entity_id), do: socket |> assign(:entity_id, entity_id)
  defp entity_id(socket),                do: socket.assigns[:entity_id]
end
