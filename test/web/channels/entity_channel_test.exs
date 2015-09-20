defmodule Entice.Web.EntityChannelTest do
  use Entice.Web.ChannelCase
  use Entice.Logic.Area
  alias Entice.Test.Factories


  setup do
    player = Factories.create_player("entity", HeroesAscent)
    {:ok, _, _socket} = subscribe_and_join(player[:socket], "entity:heroes_ascent", %{})
    :ok
  end


  test "join" do
    assert_push "join:ok", %{attributes: _}
  end
end
