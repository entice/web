defmodule Entice.Web.EntityChannelTest do
  use ExUnit.Case
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Web.EntityChannel
  alias Entice.Web.Account
  alias Entice.Web.Character
  alias Entice.Web.Client
  alias Entice.Web.Player
  alias Entice.Web.Token
  alias Entice.Test.Spy
  alias Entice.Entity
  alias Phoenix.Socket


  setup do
    {:ok, cid1} = Client.add(%Account{characters: [%Character{name: "Some Char1"}]})
    {:ok, eid1, _pid1} = Entity.start()
    {:ok, tid1} = Token.create_entity_token(cid1, %{entity_id: eid1, area: HeroesAscent, char: %Character{}})
    socket1 = %Socket{pid: self, router: Entice.Web.Router}
    Player.init(eid1, HeroesAscent, %Character{name: "Some Char1"})
    Spy.inject_into(eid1, self)

    EntityChannel.join(
      "entity:heroes_ascent",
      %{"client_id" => cid1,
        "entity_token" => tid1},
      socket1)

    {:ok, cid2} = Client.add(%Account{characters: [%Character{name: "Some Char2"}]})
    {:ok, eid2, _pid2} = Entity.start()
    {:ok, tid2} = Token.create_entity_token(cid2, %{entity_id: eid2, area: HeroesAscent, char: %Character{}})
    socket2 = %Socket{pid: self, router: Entice.Web.Router}
    Player.init(eid2, HeroesAscent, %Character{name: "Some Char2"})
    Spy.inject_into(eid2, self)

    EntityChannel.join(
      "entity:heroes_ascent",
      %{"client_id" => cid2,
        "entity_token" => tid2},
      socket2)

    Entice.Web.Endpoint.subscribe(self, "entity:heroes_ascent")

    {:ok, [e1: eid1, e2: eid2, s1: socket1]}
  end


  test "joining", %{e1: e1, e2: e2} do
    assert_receive {:socket_reply, %Socket.Message{
      topic: nil,
      event: "join:ok",
      payload: %{}}}

    assert_receive {:socket_reply, %Socket.Message{
      topic: nil,
      event: "join:ok",
      payload: %{}}}
  end


  test "adding entities", %{e2: e2} do
    #receive raw message (will be post processed by the socket)
    assert_receive {:socket_broadcast, %Socket.Message{
      topic: "entity:heroes_ascent",
      event: "entity_added",
      payload: %{added: ^e2, attributes: %{
        Name => _,
        Appearance => _,
        Position => _}}}}
  end


  test "getting a dump of the other entities", %{e1: e1, e2: e2} do
    #receive raw message (will be post processed by the socket)
    assert_receive {:socket_broadcast, %Socket.Message{
      topic: "entity:heroes_ascent",
      event: "entity_dump",
      payload: %{new: ^e2, existing: ^e1, attributes: %{
        Name => _,
        Appearance => _,
        Position => _}}}}
  end


  # test "removing entities", %{e1: e1, s1: s1} do
  #   EntityChannel.leave(:some_reason, s1)

  #   #receive raw message (will be post processed by the socket)
  #   assert_receive {:socket_broadcast, %Socket.Message{
  #     topic: "entity:heroes_ascent",
  #     event: "entity_removed",
  #     payload: %{removed: ^e1}}}
  # end
end
