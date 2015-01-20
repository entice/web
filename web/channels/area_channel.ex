defmodule Entice.Web.AreaChannel do
  use Phoenix.Channel
  use Entice.Area
  use Entice.Area.Attributes
  alias Entice.Web.Clients
  alias Entice.Web.Players
  alias Entice.Web.Groups
  alias Entice.Area
  alias Entice.Area.Entity
  alias Entice.Skills
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
      |> set_character(char)

    socket |> reply("join:ok", %{entity: entity_id, entities: Entity.get_entity_dump(map_mod)})
    {:ok, socket}
  end


  # Incoming Event API


  def handle_in("area:change", %{"map" => map}, socket) do
    {:ok, map_mod} = Area.get_map(camelize(map))
    {:ok, token} = Clients.create_transfer_token(socket |> client_id, :area, %{
      area: map_mod,
      char: socket |> character
    })

    # TODO: if in a group, initiate group area change here.

    socket |> reply("area:change:ok", %{client_id: socket |> client_id, transfer_token: token})
    {:leave, socket}
  end


  def handle_in("entity:move", %{
      "pos" => %{"x" => x, "y" => y},
      "goal" => %{"x" => gx, "y" => gy},
      "movetype" => mtype,
      "speed" => speed}, socket) when 0 < mtype and mtype < 10 and -1 < speed and speed < 2 do

    #pos upd
    Entity.put_attribute(socket |> area, socket |> entity_id,
      %Position{pos: %Coord{x: x, y: y}})
    # move upd
    Entity.put_attribute(socket |> area, socket |> entity_id,
      %Movement{goal: %Coord{x: gx, y: gy}, movetype: mtype, speed: speed})

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


  def handle_in("skillbar:set", %{"slot" => slot, "id" => id}, socket) when 0 < slot < 10 do
    # replace with a sophisticated check of the client's skills
    {:ok, skill} = Skills.get_skill(id)
    Entity.update_attribute(socket |> area, socket |> entity_id,
      SkillBar,
      fn s -> %SkillBar{slots: Map.put(s.slots, slot, skill)} end)
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


  def handle_out("entity:attribute:update", %{:entity_id => _id, SkillBar => %SkillBar{slots: slots}} = msg, socket) do
    socket |> reply(
      "entity:attribute:update",
      %{msg | SkillBar => %SkillBar{
        slots: Enum.map(slots, fn {slot, skill} -> {slot, skill.id} end)}})
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

  defp set_character(socket, character), do: socket |> assign(:character, character)
  defp character(socket),                do: socket.assigns[:character]
end
