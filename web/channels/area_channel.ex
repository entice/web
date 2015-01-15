defmodule Entice.Web.AreaChannel do
  use Phoenix.Channel
  use Entice.Area
  use Entice.Area.Attributes
  alias Entice.Web.Clients
  alias Entice.Web.Players
  alias Entice.Web.Groups
  alias Entice.Area
  alias Entice.Area.Entity
  import Phoenix.Naming


  # Initilizing the connection


  def join("area:" <> map, %{"client_id" => client_id, "transfer_token" => token}, socket) do
    {:ok, ^token, :area, %{area: map_mod, char: char}} = Clients.get_transfer_token(client_id)
    {:ok, ^map_mod} = Area.get_map(camelize(map))
    Clients.delete_transfer_token(client_id)

    {:ok, entity_id} = Players.prepare_player(map_mod, char)

    socket = socket
      |> set_area(map_mod)
      |> set_entity_id(entity_id)
      |> set_client_id(client_id)

    socket |> reply("join:ok", %{entity: entity_id, entities: Entity.get_entity_dump(map_mod)})
    {:ok, socket}
  end


  # Incoming Event API


  def handle_in("entity:move", %{"pos" => %{"x" => x, "y" => y}}, socket) do
    Entity.put_attribute(socket |> area, socket |> entity_id,
      %Position{pos: %Coord{x: x, y: y}})
    {:ok, socket}
  end


  def handle_in("group:merge", %{"target" => id}, socket) do
    Groups.merge(socket |> area, socket |> entity_id, id)
    {:ok, socket}
  end


  def handle_in("group:kick", %{"target" => id}, socket) do
    Groups.kick(socket |> area, socket |> entity_id, id)
    {:ok, socket}
  end


  def handle_in(event, _data, socket) do
    socket |> reply(event <> ":error", %{})
    {:leave, socket}
  end


  # Outgoing Event API


  def handle_out("entity:add", %{entity_id: id, attributes: _attrs} = msg, socket) do
    if (id != socket |> entity_id), do: socket |> reply("entity:add", msg)
    {:ok, socket}
  end


  def handle_out(event, message, socket) do
    reply(socket, event, message)
    {:ok, socket}
  end


  # Socket leave


  def leave(_msg, socket) do
    Players.delete_player(socket |> area, socket |> entity_id)
    {:ok, socket}
  end


  # Internal


  defp set_area(socket, area),           do: socket |> assign(:area, area)
  defp area(socket),                     do: socket.assigns[:area]

  defp set_entity_id(socket, entity_id), do: socket |> assign(:entity_id, entity_id)
  defp entity_id(socket),                do: socket.assigns[:entity_id]

  defp set_client_id(socket, client_id), do: socket |> assign(:client_id, client_id)
  defp client_id(socket),                do: socket.assigns[:client_id]
end
