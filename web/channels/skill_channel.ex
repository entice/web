defmodule Entice.Web.SkillChannel do
  use Phoenix.Channel
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Entity
  alias Entice.Skills
  alias Entice.Logic.Area
  alias Entice.Web.Character
  alias Entice.Web.Token
  alias Entice.Web.Observer
  import Phoenix.Naming
  import Entice.Web.ChannelHelper


  def join("skill:" <> map, %{"client_id" => client_id, "entity_token" => token}, socket) do
    {:ok, ^token, :entity, %{map: map_mod, entity_id: entity_id, char: char}} = Token.get_token(client_id)
    {:ok, ^map_mod} = Area.get_map(camelize(map))

    Observer.init(entity_id)
    Observer.notify_active(entity_id, "skill:" <> map, [])

    socket = socket
      |> set_map(map_mod)
      |> set_entity_id(entity_id)
      |> set_client_id(client_id)
      |> set_character(char)

    # retrieve skill bar here
    skillbar = %SkillBar{slots: to_skills(char)}
    Entity.put_attribute(entity_id, skillbar)

    socket |> reply("join:ok", %{unlocked_skills: char.available_skills, skillbar: to_skill_ids(skillbar.slots)})
    {:ok, socket}
  end


  def handle_in("skillbar:set", %{"slot" => slot, "id" => id}, socket) when slot in 0..10 and id > -1 do
    # replace with a sophisticated check of the client's skills
    {:ok, skill} = Skills.get_skill(id)
    map_mod = socket |> map

    case map_mod.is_outpost? do
      false -> socket |> reply("skillbar:error", %{})
      true  ->
        new_slots = case Entity.fetch_attribute(socket |> entity_id, SkillBar) do
          {:ok, skillbar} -> skillbar.slots |> List.replace_at((slot - 1), skill)
          _               -> %{}
        end

        Entice.Web.Repo.update(%{(socket |> character) | skillbar: to_skill_ids(new_slots)})
        Entity.put_attribute(socket |> entity_id, %SkillBar{slots: new_slots})

        socket |> reply("skillbar:ok", %{skillbar: to_skill_ids(new_slots)})
    end

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
    Entity.remove_attribute(socket |> entity_id, SkillBar)
    {:ok, socket}
  end


  # Internal


  defp to_skills(%Character{skillbar: skillbar}), do: to_skills(skillbar)
  defp to_skills(skillbar) when is_list(skillbar) do
    skillbar
    |> Enum.map(fn skill_id ->
        {:ok, skill} = Skills.get_skill(skill_id)
        skill
      end)
  end

  defp to_skill_ids(skillbar) when is_list(skillbar) do
    skillbar
    |> Enum.map(fn skill -> skill.id end)
  end
end
