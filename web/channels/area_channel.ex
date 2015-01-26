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


  # Initializing the connection


  def join("area:" <> map, %{"client_id" => client_id, "transfer_token" => token}, socket) do
    {:ok, ^token, token_type, %{area: map_mod, char: char} = payload} = Clients.get_transfer_token(client_id)
    {:ok, ^map_mod} = Area.get_map(camelize(map))
    Clients.delete_transfer_token(client_id)

    # link the client and the entity to the new socket
    {:ok, entity_id} = case token_type do
      :area        -> Players.prepare_new_player(map_mod, socket, char)
      :area_change -> Players.prepare_grouped_player(map_mod, socket, char, payload[:entity_id], payload[:group_id])
    end
    :ok = Clients.add_socket(client_id, socket)

    socket = socket
      |> set_area(map_mod)
      |> set_entity_id(entity_id)
      |> set_client_id(client_id)
      |> set_character(char)

    # filter the dump
    dump = Entity.get_entity_dump(map_mod)
      |> Enum.map(&(%{&1| attributes: Map.delete(&1.attributes, Players.Network)}))

    socket |> reply("join:ok", %{entity: entity_id, entities: dump })
    {:ok, socket}
  end


  # Incoming Event API


  def handle_in("area:change", %{"map" => map}, socket) do
    {:ok, map_mod} = Area.get_map(camelize(map))

    case Groups.get_my_members(socket |> area, socket |> entity_id) do
      [_|_] -> area_change_group(map_mod, Groups.get_for(socket |> area, socket |> entity_id), socket)
      []    -> area_change_single(map_mod, socket)
    end
  end


  def handle_in("entity:move", %{
      "pos" => %{"x" => x, "y" => y},
      "goal" => %{"x" => gx, "y" => gy},
      "plane" => plane,
      "movetype" => mtype,
      "speed" => speed}, socket) when mtype in 0..10 and speed in -1..2 do

    #pos upd
    Entity.put_attribute(socket |> area, socket |> entity_id,
      %Position{pos: %Coord{x: x, y: y}})
    # move upd
    Entity.put_attribute(socket |> area, socket |> entity_id,
      %Movement{goal: %Coord{x: gx, y: gy}, plane: plane, movetype: mtype, speed: speed})

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


  def handle_in("skillbar:set", %{"slot" => slot, "id" => id}, socket) when slot in 0..10 and id > 0 do
    # replace with a sophisticated check of the client's skills
    {:ok, skill} = Skills.get_skill(id)
    Entity.update_attribute(socket |> area, socket |> entity_id,
      SkillBar, fn s -> %SkillBar{slots: Map.put(s.slots, slot, skill)} end)
    {:ok, socket}
  end

  def handle_in("skillbar:set", %{"slot" => slot, "id" => 0}, socket) when slot in 0..10 do
    Entity.update_attribute(socket |> area, socket |> entity_id,
      SkillBar, fn s -> %SkillBar{slots: Map.delete(s.slots, slot)} end)
    {:ok, socket}
  end


  def handle_in(event, _data, socket) do
    socket |> reply(event <> ":error", %{})
    {:leave, socket}
  end


  # Outgoing Event API


  def handle_out("entity:add", %{entity_id: id, attributes: attrs} = msg, socket) do
    if (id != socket |> entity_id), do: socket |> reply("entity:add", %{msg | attributes: Map.delete(attrs, Players.Network)})
    {:ok, socket}
  end


  def handle_out("entity:attribute:update", %{:entity_id => _id, SkillBar => %SkillBar{slots: slots}} = msg, socket) do
    socket |> reply(
      "entity:attribute:update",
      %{msg | SkillBar => %SkillBar{
        slots: Enum.map(slots, fn {slot, skill} -> %{slot: slot, id: skill.id} end)}})
    {:ok, socket}
  end


  def handle_out("entity:attribute:update", %{:entity_id => _id, Players.Network => _net}, socket) do
    # simply drop, since internal
    {:ok, socket}
  end


  def handle_out("area:change:pre", %{map: map_mod, entity_id: entity_id, group_id: group_id}, socket) do
    {:ok, token} = Clients.create_transfer_token(socket |> client_id, :area_change, %{
      area: map_mod,
      char: socket |> character,
      entity_id: entity_id,
      group_id: group_id})

    socket |> reply("area:change:force", %{
      client_id: socket |> client_id,
      transfer_token: token,
      map: map_mod.underscore_name})

    {:leave, socket}
  end


  def handle_out(event, message, socket) do
    reply(socket, event, message)
    {:ok, socket}
  end


  # Socket leave


  def leave(_msg, socket) do
    Players.delete_player(socket |> area, socket |> entity_id)
    Clients.remove_socket(socket |> client_id, socket)
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

  defp area_change_single(map_mod, socket) do
    {:ok, token} = Clients.create_transfer_token(socket |> client_id, :area, %{
      area: map_mod,
      char: socket |> character})

    socket |> reply("area:change:ok", %{
      client_id: socket |> client_id,
      transfer_token: token})

    {:leave, socket}
  end

  defp area_change_group(map_mod, {:ok, group_id, group}, socket) do
    all_members    = [group.leader | group.members]
    new_group_dict = Groups.prepare_area_change(socket |> area, map_mod, group_id)

    # prepare members
    for member <- all_members do
      Players.get_socket(socket |> area, member)
      |> reply("area:change:pre", %{
        map: map_mod,
        entity_id: new_group_dict[member],
        group_id: new_group_dict[group_id]})
    end

    {:ok, socket}
  end
end
