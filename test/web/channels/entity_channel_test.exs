defmodule Entice.Web.EntityChannelTest do
  use Entice.Web.ChannelCase
  use Entice.Logic.Area
  alias Entice.Test.Factories


  setup do
    player = Factories.create_player("entity", HeroesAscent)
    {:ok, _, socket} = subscribe_and_join(player[:socket], "entity:heroes_ascent", %{})
    {:ok, [socket: socket]}
  end


  test "join" do
    assert_push "join:ok", %{attributes: _}
  end


  test "mapchange", %{socket: socket} do
    new_map = TeamArenas.underscore_name
    ref = push socket, "map:change", %{"map" => new_map}
    assert_reply ref, :ok, %{map: ^new_map}
  end
end
