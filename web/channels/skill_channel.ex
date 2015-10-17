defmodule Entice.Web.SkillChannel do
  use Entice.Web.Web, :channel
  alias Entice.Entity.Coordination
  alias Entice.Logic.Skills
  alias Entice.Logic.Area
  alias Entice.Logic.SkillBar
  alias Phoenix.Socket


  def join("skill:" <> map, _message, %Socket{assigns: %{map: map_mod}} = socket) do
    {:ok, ^map_mod} = Area.get_map(camelize(map))
    Process.flag(:trap_exit, true)
    send(self, :after_join)
    {:ok, socket}
  end


  def handle_info(:after_join, %Socket{assigns: %{entity_id: entity_id, character: char}} = socket) do
    Coordination.register_observer(self)
    :ok = SkillBar.register(entity_id, char.skillbar)
    socket |> push("initial", %{unlocked_skills: char.available_skills, skillbar: entity_id |> SkillBar.get_skills})
    {:noreply, socket}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}


  # Incoming


  def handle_in("skillbar:set", %{"slot" => slot, "id" => id}, socket) when slot in 0..10 and id > -1 do
    skill_bits = :erlang.list_to_integer((socket |> character).available_skills |> String.to_char_list, 16)
    unlocked = Entice.Utils.BitOps.get_bit(skill_bits, id)
    IO.puts "UNLOCKED 3" #Unlocked is 1 should be 0
    IO.puts unlocked
    case unlocked do
      1 ->
        case {Skills.get_skill(id), (socket |> map).is_outpost?} do
          {nil, _}  -> {:reply, :error, socket}
          {_, true} ->
            new_slots = socket |> entity_id |> SkillBar.change_skill(slot, id)
            Entice.Web.Repo.update(%{(socket |> character) | skillbar: new_slots})
            {:reply, {:ok, %{skillbar: new_slots}}, socket}
        end
      0 -> {:reply, :error, socket}
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
      {:error, reason} -> {:reply, {:error, %{slot: slot, reason: reason}}, socket}
      {:ok, :normal, skill} ->
        socket |> broadcast("cast:start", %{
          entity: socket |> entity_id,
          slot: slot,
          skill: skill.id,
          cast_time: skill.cast_time})
        {:reply, :ok, socket}
      {:ok, :instant, skill} ->
        socket |> broadcast("cast:instantly", %{
          entity: socket |> entity_id,
          slot: slot,
          skill: skill.id,
          recharge_time: skill.recharge_time})
        {:reply, :ok, socket}
    end
  end


  # Leaving the socket (voluntarily or forcefully)


  def terminate(_msg, socket) do
    SkillBar.unregister(socket |> entity_id)
    :ok
  end
end
