defmodule Entice.Web.SkillChannelTest do
  use Entice.Web.ChannelCase
  use Entice.Logic.Area
  alias Entice.Web.Socket.Helpers
  alias Entice.Web.Character
  alias Entice.Logic.Skills
  alias Entice.Test.Factories

  setup do
    player = Factories.create_player("skill", HeroesAscent)

    #Lock skill
    id = 4
    #Update char not sure if necessary
    new_character = Character.set_skills(player.character)
    skills = :erlang.integer_to_list(Entice.Utils.BitOps.unset_bit(Skills.max_unlocked_skills, id), 16) |> to_string
    new_character = %{new_character | available_skills: skills}
    #Update player and socket
    new_socket = player[:socket] |> Entice.Web.Socket.Helpers.set_character(new_character)
    player = Map.update(player, :character, new_character, fn(_char) -> new_character end)
    player = Map.update(player, :socket, new_socket, fn(_socket) -> new_socket end)
    {:ok, _, socket} = subscribe_and_join(player[:socket], "skill:heroes_ascent", %{})

    {:ok, [player: player, socket: socket, skill_id: id]}
  end


  test "join" do
    assert_push "initial", %{unlocked_skills: _, skillbar: _}
  end

  test "skillbar:set skill not unlocked", %{player: player, socket: socket, skill_id: id} do
    ref = push socket, "skillbar:set", %{"slot" => 0, "id" => id}
    assert_reply ref, :error
  end
end
