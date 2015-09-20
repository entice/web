defmodule Entice.Web.SkillChannelTest do
  use Entice.Web.ChannelCase
  use Entice.Logic.Area
  alias Entice.Test.Factories


  setup do
    player = Factories.create_player("skill", HeroesAscent)
    {:ok, _, _socket} = subscribe_and_join(player[:socket], "skill:heroes_ascent", %{})
    :ok
  end


  test "join" do
    assert_push "join:ok", %{unlocked_skills: _, skillbar: _}
  end
end
