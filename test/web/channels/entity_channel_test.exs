defmodule Entice.Web.EntityChannelTest do
  use Entice.Web.ChannelCase
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Entity
  alias Entice.Test.Factories


  setup do
    player = Factories.create_player(HeroesAscent)
    {eid, _pid} = Factories.create_entity()

    {:ok, _, socket} = subscribe_and_join(player[:socket], "entity:heroes_ascent", %{})
    {:ok, [socket: socket, entity_id: player[:entity_id], other_entity_id: eid]}
  end


  test "join" do
    assert_push "initial", %{attributes: _}
  end


  test "entity spawn" do
    {:ok, eid, _pid} = Entity.start(UUID.uuid4(), [%Position{}, %Name{}])
    assert_push "add", %{
      entity: ^eid,
      attributes: %{
        "position" => %{x: _, y: _, plane: _},
        "name"     => _}}
  end


  test "entity attr add", %{other_entity_id: eid} do
    Entity.attribute_transaction(eid,
      fn _ -> %{
        Position => %Position{},
        Name => %Name{},
        Health => %Health{}} end)
    empty_map = %{}
    assert_push "change", %{
      entity: ^eid,
      added: %{
        "position" => %{x: _, y: _, plane: _},
        "name"     => _,
        "health"   => %{health: _, max_health: _}},
      changed: ^empty_map,
      removed: ^empty_map}
  end


  test "entity attr change", %{other_entity_id: eid} do
    # first add some stuff
    Entity.attribute_transaction(eid,
      fn _ -> %{Position => %Position{}, Name => %Name{}} end)
    # then change it, position should not be in the update
    Entity.attribute_transaction(eid,
      fn _ -> %{Position => %Position{plane: 42}, Name => %Name{name: "Rababerabar"}} end)
    empty_map = %{}
    only_name = %{"name" => "Rababerabar"}
    assert_push "change", %{
      entity: ^eid,
      added: ^empty_map,
      changed: ^only_name,
      removed: ^empty_map}
  end


  test "entity leave", %{other_entity_id: eid} do
    Entity.stop(eid)
    assert_push "remove", %{entity: ^eid}
  end


  test "getting kicked", %{socket: socket, entity_id: eid} do
    Process.monitor socket.channel_pid
    Entity.stop(eid)
    assert_receive {:DOWN, _, _, _, _}
  end


  test "mapchange", %{socket: socket} do
    new_map = TeamArenas.underscore_name
    ref = push socket, "map:change", %{"map" => new_map}
    assert_reply ref, :ok, %{map: ^new_map}
  end
end
