defmodule Entice.Web.AreaChannel do
  use Phoenix.Channel
  use Entice.Area.Attributes
  alias Entice.Area
  alias Entice.Area.Entity
  import Phoenix.Naming

  @channel "area"

  def join(socket, map, _handshake_msg) do
    join_internal(socket, map |> camelize |> Area.get_map)
  end

  defp join_internal(socket, {:error, _}), do: {:error, socket, :unauthorized}
  defp join_internal(socket, {:ok, map}) do
    {:ok, id} = prepare_player(map)

    socket = socket
      |> set_area(map)
      |> set_entity_id(id)
      |> subscribe(@channel, map.underscore_name)

    socket |> reply("join:ok", %{entity: id, entities: Entity.get_entity_dump(map)})
    {:ok, socket}
  end


  def event(socket, "area:move_entity", %{"pos" => %{"x" => x, "y" => y}}) do
    Entity.put_attribute(socket |> area, socket |> entity_id,
      %Position{pos: %Coord{x: x, y: y}})
    socket
  end


  def leave(socket, _msg) do
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
