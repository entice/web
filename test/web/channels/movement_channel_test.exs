defmodule Entice.Web.MovementChannelTest do
  use Entice.Web.ChannelCase
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Entity
  alias Entice.Test.Factories


  setup do
    player = Factories.create_player("movement", HeroesAscent)
    {:ok, _, socket} = subscribe_and_join(player[:socket], "movement:heroes_ascent", %{})
    {:ok, [socket: socket, entity_id: player[:entity_id]]}
  end


  test "join" do
    assert_push "join:ok", %{}
  end


  test "update position etc.", %{socket: socket, entity_id: eid} do
    socket |> push("update", %{
      "pos" => %{"x" => 42, "y" => 1337, "plane" => 13},
      "goal" => %{"x" => 1337, "y" => 42, "plane" => 7},
      "movetype" => 9,
      "velocity" => 0.1337})

    assert_broadcast "update", %{
      entity: ^eid,
      pos: _,
      goal: _,
      movetype: _,
      velocity: _}

    assert %Position{pos: %Coord{x: 42, y: 1337}} = Entity.get_attribute(eid, Position)
  end
end
