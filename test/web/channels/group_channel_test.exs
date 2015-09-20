defmodule Entice.Web.GroupChannelTest do
  use Entice.Web.ChannelCase
  use Entice.Logic.Area
  alias Entice.Test.Factories


  setup do
    player = Factories.create_player("group", HeroesAscent)
    {:ok, _, _socket} = subscribe_and_join(player[:socket], "group:heroes_ascent", %{})
    :ok
  end


  test "join" do
    assert_push "join:ok", %{}
  end
end
