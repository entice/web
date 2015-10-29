defmodule Entice.Web.SkillChannel do
  use Entice.Web.Web, :channel
  alias Entice.Entity.Coordination
  alias Entice.Logic.Skills
  alias Entice.Logic.Area
  alias Entice.Logic.SkillBar
  alias Entice.Logic.Casting
  alias Phoenix.Socket


  def join("skill:" <> map, _message, %Socket{assigns: %{map: map_mod}} = socket) do
    {:ok, ^map_mod} = Area.get_map(camelize(map))
    Process.flag(:trap_exit, true)
    send(self, :after_join)
    {:ok, socket}
  end


  def handle_info(:after_join, %Socket{assigns: %{entity_id: entity_id, character: char}} = socket) do
    Coordination.register_observer(self, socket |> map)
    SkillBar.register(entity_id, char.skillbar)
    Casting.register(entity_id)
    socket |> push("initial", %{unlocked_skills: char.available_skills, skillbar: entity_id |> SkillBar.get_skills})
    {:noreply, socket}
  end

  def handle_info(
      {:skill_casted, %{
        entity_id: entity_id,
        target_entity_id: target_id,
        slot: slot,
        skill: skill,
        recharge_time: recharge_time}}, socket) do
    socket |> broadcast("cast:end", %{
      entity: entity_id,
      target: target_id,
      slot: slot,
      skill: skill.id,
      recharge_time: recharge_time})
    {:noreply, socket}
  end

  def handle_info(
      {:skill_cast_interrupted, %{
        entity_id: entity_id,
        target_entity_id: target_id,
        slot: slot,
        skill: skill,
        recharge_time: recharge_time,
        reason: reason}}, socket) do
    socket |> broadcast("cast:interrupted", %{
      entity: entity_id,
      target: target_id,
      slot: slot,
      skill: skill.id,
      recharge_time: recharge_time,
      reason: reason})
    {:noreply, socket}
  end

  def handle_info(
      {:skill_recharged, %{
        entity_id: entity_id,
        slot: slot,
        skill: skill}}, socket) do
    socket |> broadcast("recharge:end", %{
      entity: entity_id,
      slot: slot,
      skill: skill.id})
    {:noreply, socket}
  end

  def handle_info({:after_cast_delay_ended, %{entity_id: entity_id}}, socket) do
    socket |> broadcast("after_cast:end", %{entity: entity_id})
    {:noreply, socket}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}


  # Incoming


  def handle_in("skillbar:set", %{"slot" => slot, "id" => id}, socket) when slot in 0..10 and id > -1 do
    skill_bits = :erlang.list_to_integer((socket |> character).available_skills |> String.to_char_list, 16)
    unlocked = Entice.Utils.BitOps.get_bit(skill_bits, id)

    case {unlocked, Skills.get_skill(id), (socket |> map).is_outpost?} do
      {_, nil, _}   -> {:reply, {:error, %{reason: :undefined_skill}}, socket}
      {0, _, _}     -> {:reply, {:error, %{reason: :unavailable_skill}}, socket}
      {_, _, false} -> {:reply, {:error, %{reason: :cannot_change_skill_in_explorable}}, socket}
      _ ->
        new_slots = socket |> entity_id |> SkillBar.change_skill(slot, id)
        Entice.Web.Repo.update(%{(socket |> character) | skillbar: new_slots})
        {:reply, {:ok, %{skillbar: new_slots}}, socket}
    end
  end

  def handle_in("cast", %{"slot" => slot} = msg, socket) when slot in 0..10 do
    skill = SkillBar.get_skill(socket |> entity_id, slot)
    target = Map.get(msg, "target", socket |> entity_id)

    case socket |> entity_id |> Casting.cast_skill(skill, slot, target, self) do
      {:error, reason} -> {:reply, {:error, %{slot: slot, reason: reason}}, socket}
      {:ok, skill, cast_time} ->
        socket |> broadcast("cast:start", %{
          entity: socket |> entity_id,
          target: target,
          slot: slot,
          skill: skill.id,
          cast_time: cast_time})
        {:reply, :ok, socket}
    end
  end


  # Leaving the socket (voluntarily or forcefully)


  def terminate(_msg, socket) do
    SkillBar.unregister(socket |> entity_id)
    :ok
  end
end
