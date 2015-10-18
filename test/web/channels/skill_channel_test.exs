defmodule Entice.Web.SkillChannelTest do
  use Entice.Web.ChannelCase
  use Entice.Logic.Area
  alias Entice.Web.Socket.Helpers
  alias Entice.Logic.Skills
  alias Entice.Logic.Vitals
  alias Entice.Test.Factories

  setup do
    player = Factories.create_player(HeroesAscent)
    player[:entity_id] |> Vitals.register

    locked_skill_id = 4
    skills = :erlang.integer_to_list(Entice.Utils.BitOps.unset_bit(Skills.max_unlocked_skills, locked_skill_id), 16) |> to_string

    {:ok, new_character} = Entice.Web.Repo.insert(%{player.character | available_skills: skills})

    {:ok, _, socket} = subscribe_and_join(player[:socket] |> Helpers.set_character(new_character), "skill:heroes_ascent", %{})

    {:ok, [socket: socket, locked_skill_id: locked_skill_id]}
  end


  test "join" do
    assert_push "initial", %{unlocked_skills: _, skillbar: _}
  end

  test "skillbar:set skill not unlocked", %{socket: socket, locked_skill_id: locked_skill_id} do
    ref = push socket, "skillbar:set", %{"slot" => 0, "id" => locked_skill_id}
    assert_reply ref, :error, _reason
  end

  test "simple casting", %{socket: socket} do
    ref = push socket, "skillbar:set", %{"slot" => 0, "id" => Skills.HealingSignet.id}
    assert_reply ref, :ok
    ref = push socket, "cast", %{"slot" => 0}
    assert_reply ref, :ok
    assert_broadcast "cast:start", %{entity: id, target: id, slot: 0, skill: _, cast_time: cast_time}
    assert_broadcast "cast:end", %{entity: id, target: id, slot: 0, skill: _, recharge_time: recharge_time}, (cast_time + 100)
    assert_broadcast "after_cast:end", %{entity: _}, (Entice.Logic.Casting.after_cast_delay + 100)
    assert_broadcast "recharge:end", %{entity: _, slot: 0, skill: _}, (recharge_time - Entice.Logic.Casting.after_cast_delay + 100)
  end
end
