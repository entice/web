defmodule Entice.Web.SkillChannel do
  use Phoenix.Channel
  use Entice.Logic.Area
  alias Entice.Entity
  alias Entice.Skills
  alias Entice.Logic.Area
  alias Entice.Logic.SkillBar
  alias Entice.Web.Token
  alias Entice.Web.Observer
  import Phoenix.Naming
  import Entice.Web.ChannelHelper


  def join("skill:" <> map, %{"client_id" => client_id, "entity_token" => token}, socket) do
    {:ok, ^token, :entity, %{map: map_mod, entity_id: entity_id, char: char}} = Token.get_token(client_id)
    {:ok, ^map_mod} = Area.get_map(camelize(map))

    Observer.register(entity_id)
    Observer.notify_active(entity_id, "skill:" <> map, [])

    :ok = SkillBar.register(entity_id, char.skillbar)

    socket = socket
      |> set_map(map_mod)
      |> set_entity_id(entity_id)
      |> set_client_id(client_id)
      |> set_character(char)

    socket |> reply("join:ok", %{unlocked_skills: char.available_skills, skillbar: entity_id |> SkillBar.get_skills})
    {:ok, socket}
  end


  def handle_in("skillbar:set", %{"slot" => slot, "id" => id}, socket) when slot in 0..10 and id > -1 do
    # TODO add a more sophisticated check of the client's available skills
    case (socket |> map).is_outpost? do
      false -> socket |> reply("skillbar:error", %{})
      true  ->
        new_slots = socket |> entity_id |> SkillBar.change_skill(slot, id)
        Entice.Web.Repo.update(%{(socket |> character) | skillbar: new_slots})
        socket |> reply("skillbar:ok", %{skillbar: new_slots})
    end
  end


  def handle_in("cast", %{"slot" => slot}, socket) when slot in 0..10 do
    cast_callback = fn skill ->
      Entice.Web.Endpoint.broadcast(socket.topic, "cast:end", %{
        entity: socket |> entity_id,
        slot: slot,
        skill: skill.id,
        recharge_time: skill.recharge_time})
    end
    recharge_callback = fn skill ->
      Entice.Web.Endpoint.broadcast(socket.topic, "recharge:end", %{
        entity: socket |> entity_id,
        slot: slot,
        skill: skill.id})
    end
    case socket |> entity_id |> SkillBar.cast_skill(slot, cast_callback, recharge_callback) do
      {:error, reason} -> socket |> reply("cast:error", %{slot: slot, reason: reason})
      {:ok, :normal, skill} ->
        socket |> broadcast("cast:start", %{
          entity: socket |> entity_id,
          slot: slot,
          skill: skill.id,
          cast_time: skill.cast_time})
        socket |> reply("cast:ok", %{})
      {:ok, :instant, skill} ->
        socket |> broadcast("cast:instantly", %{
          entity: socket |> entity_id,
          slot: slot,
          skill: skill.id,
          recharge_time: skill.recharge_time})
        socket |> reply("cast:ok", %{})
    end
  end


  def handle_out("cast:" <> evt, %{entity: _entity_id, slot: _slot} = msg, socket),
  do: socket |> reply("cast:" <> evt, msg)


  def handle_out("recharge:end", %{entity: _entity_id, slot: _slot} = msg, socket),
  do: socket |> reply("recharge:end", msg)


  def handle_out("terminated", %{entity_id: entity_id}, socket) do
    case (entity_id == socket |> entity_id) do
      true  -> {:leave, socket}
      false -> {:ok, socket}
    end
  end


  def handle_out(_event, _message, socket), do: {:ok, socket}


  def leave(_msg, socket) do
    Observer.notify_inactive(socket |> entity_id, socket.topic)
    Entity.remove_attribute(socket |> entity_id, SkillBar)
    {:ok, socket}
  end
end
