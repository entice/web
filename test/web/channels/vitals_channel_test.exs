defmodule Entice.Web.VitalsChannelTest do
  use Entice.Web.ChannelCase
  use Entice.Logic.Maps
  alias Entice.Logic.Vitals
  alias Entice.Test.Factories

  setup do
    player = Factories.create_player(HeroesAscent)
    {:ok, _, _socket} = subscribe_and_join(player[:socket], "vitals:heroes_ascent", %{})
    {:ok, [entity: player[:entity_id]]}
  end


  test "entity death propagation", %{entity: eid} do
    Vitals.kill(eid)
    assert_broadcast "entity:dead", %{entity: ^eid}
  end
end
