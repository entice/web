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
    {:ok, cid1, _pid} = Client.add(%Account{characters: [%Character{name: "Some Char1"}]})
    {:ok, eid1, pid1} = Entity.start()
    {:ok, tid1} = Token.create_entity_token(cid1, %{entity_id: eid1, area: HeroesAscent, char: %Character{}})
    socket1 = %Socket{pid: pid1, router: Entice.Web.Router}
    Player.init(eid1, HeroesAscent, %Character{name: "Some Char1"})
    Spy.inject_into(eid1, self)

    EntityChannel.join(
      "entity:heroes_ascent",
      %{"client_id" => cid1,
        "entity_token" => tid1},
      socket1)

    {:ok, cid2, _pid} = Client.add(%Account{characters: [%Character{name: "Some Char2"}]})
    {:ok, eid2, pid2} = Entity.start()
    {:ok, tid2} = Token.create_entity_token(cid2, %{entity_id: eid2, area: HeroesAscent, char: %Character{}})
    socket2 = %Socket{pid: pid2, router: Entice.Web.Router}
    Player.init(eid2, HeroesAscent, %Character{name: "Some Char2"})
    Spy.inject_into(eid2, self)

    EntityChannel.join(
      "entity:heroes_ascent",
      %{"client_id" => cid2,
        "entity_token" => tid2},
      socket2)

    {:ok, [e1: eid1, e2: eid2, c1: cid1, c2: cid2]}
  end


  test "joining", %{e1: e1, e2: e2} do
    assert_receive %{
    sender: ^e1,
    event: {:socket_reply, %Socket.Message{
      topic: nil,
      event: "join:ok",
      payload: %{entity: ^e1}}}}

    assert_receive %{
      sender: ^e2,
      event: {:socket_reply, %Socket.Message{
        topic: nil,
        event: "join:ok",
        payload: %{entity: ^e2}}}}
  end


  test "getting a dump of the other entities", %{e1: e1, e2: e2} do
    #receive raw message (will be post processed by the socket)
    assert_receive %{
      sender: ^e2,
      event: {:socket_broadcast, %Socket.Message{
        topic: "dump:heroes_ascent",
        event: "entity_dump",
        payload: %{new: ^e2, existing: ^e1, attributes: %{
          Name => _,
          }}}}}
  end
end
