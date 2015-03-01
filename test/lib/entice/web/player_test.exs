defmodule Entice.Logic.PlayerTest do
  use ExUnit.Case
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Entity
  alias Entice.Web.Character
  alias Entice.Web.Player


  setup do
    {:ok, eid, _pid} = Entity.start

    Player.init(eid, HeroesAscent, %Character{})

    Entice.Web.Endpoint.subscribe(self, "test:player")

    {:ok, [entity_id: eid]}
  end


  test "correct init", %{entity_id: eid} do
    assert Entity.has_attribute?(eid, Name) == true
    assert Entity.has_attribute?(eid, Position) == true
    assert Entity.has_attribute?(eid, Appearance) == true

    assert Entity.has_behaviour?(eid, Player.Behaviour) == true
  end


  test "notify mapchange if subscribed", %{entity_id: eid} do
    Player.add_listener(eid, "test:player")

    Player.notify_mapchange(eid, RandomArenas)

    assert_receive {:socket_broadcast, %{
      topic: "test:player",
      event: "mapchange",
      payload: %{
        entity_id: ^eid,
        map: RandomArenas,
        attributes: _}}}
  end


  test "dont notify mapchange if unsubscribed", %{entity_id: eid} do
    Player.add_listener(eid, "test:player")

    Player.remove_listener(eid, "test:player")

    Player.notify_mapchange(eid, RandomArenas)

    refute_receive {:socket_broadcast, %{
      topic: "test:player",
      event: "mapchange",
      payload: _}}
  end
end
