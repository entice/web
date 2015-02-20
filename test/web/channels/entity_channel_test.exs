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
  alias Entice.Entity
  alias Phoenix.Socket
  alias Phoenix.Channel.Transport


  setup do
    {:ok, cid1} = Client.add(%Account{characters: [%Character{name: "Some Char1"}]})
    {:ok, eid1, _pid1} = Entity.start()
    {:ok, tid1} = Token.create_entity_token(cid1, %{entity_id: eid1, area: HeroesAscent, char: %Character{}})
    socket1 = %Socket{pid: self, router: Entice.Web.Router, topic: "entity:heroes_ascent", assigns: [], transport: Phoenix.Transports.WebSocket, pubsub_server: Entice.Web.PubSub}
    Player.init(eid1, HeroesAscent, %Character{name: "Some Char1"})

    assert {:ok, socket1} = Transport.dispatch(socket1, "entity:heroes_ascent", "join", %{"client_id" => cid1, "entity_token" => tid1})

    {:ok, cid2} = Client.add(%Account{characters: [%Character{name: "Some Char2"}]})
    {:ok, eid2, _pid2} = Entity.start()
    {:ok, tid2} = Token.create_entity_token(cid2, %{entity_id: eid2, area: HeroesAscent, char: %Character{}})
    socket2 = %Socket{pid: self, router: Entice.Web.Router, topic: "entity:heroes_ascent", assigns: [], transport: Phoenix.Transports.WebSocket, pubsub_server: Entice.Web.PubSub}
    Player.init(eid2, HeroesAscent, %Character{name: "Some Char2"})

    assert {:ok, socket1} = Transport.dispatch(socket2, "entity:heroes_ascent", "join", %{"client_id" => cid2, "entity_token" => tid2})

    {:ok, [e1: eid1, e2: eid2, s1: socket1]}
  end


  test "adding entities", %{e2: e2} do
    assert_receive {:socket_broadcast, %Socket.Message{
      topic: "entity:heroes_ascent",
      event: "entity_added",
      payload: %{added: ^e2, attributes: %{
        Name => _,
        Appearance => _,
        Position => _}}}}
  end


  test "getting a dump of the other entities", %{e1: e1, e2: e2} do
    assert_receive {:socket_broadcast, %Socket.Message{
      topic: "entity:heroes_ascent",
      event: "entity_dump",
      payload: %{new: ^e2, existing: ^e1, attributes: %{
        Name => _,
        Appearance => _,
        Position => _}}}}
  end


  # test "removing entities", %{e1: e1, s1: s1} do
  #   Transport.dispatch(s1, "entity:heroes_ascent", "leave", %{})

  #   assert_receive {:socket_broadcast, %Socket.Message{
  #     topic: "entity:heroes_ascent",
  #     event: "entity_removed",
  #     payload: %{removed: ^e1}}}
  # end
end
