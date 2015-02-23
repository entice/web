defmodule Entice.Web.EntityChannelTest do
  use ExUnit.Case
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Test.Spy
  alias Entice.Test.Factories
  alias Entice.Web.EntityChannel
  alias Phoenix.Socket.Message
  alias Phoenix.Channel.Transport


  setup do
    # player 1
    p1 = Factories.create_player("entity", HeroesAscent, true)
    Spy.inject_into(p1[:entity_id], self)

    assert {:ok, sock1} = Transport.dispatch(p1[:socket], "entity:heroes_ascent", "join", %{"client_id" => p1[:client_id], "entity_token" => p1[:token]})

    # player 2
    p2 = Factories.create_player("entity", HeroesAscent, true)
    Spy.inject_into(p2[:entity_id], self)

    assert {:ok, _sock} = Transport.dispatch(p2[:socket], "entity:heroes_ascent", "join", %{"client_id" => p2[:client_id], "entity_token" => p2[:token]})

    {:ok, [e1: p1[:entity_id], e2: p2[:entity_id], s1: sock1]}
  end


  test "join", %{e1: e1, e2: e2} do
    assert_receive %{sender: ^e1, event: {:socket_reply, %Message{
      topic: "entity:heroes_ascent",
      event: "join:ok",
      payload: %{
        name: _,
        position: _,
        appearance: _}}}}
  end


  test "adding entities", %{e1: e1, e2: e2} do
    assert_receive %{sender: ^e1, event: {:socket_broadcast, %Message{
      topic: "entity:heroes_ascent",
      event: "entity_added",
      payload: %{added: ^e2, attributes: %{
        Name => _,
        Appearance => _,
        Position => _}}}}}
  end


  test "getting a dump of the other entities", %{e1: e1, e2: e2} do
    assert_receive %{sender: ^e1, event: {:socket_broadcast, %Message{
      topic: "entity:heroes_ascent",
      event: "entity_dump",
      payload: %{new: ^e2, existing: ^e1, attributes: %{
        Name => _,
        Appearance => _,
        Position => _}}}}}
  end


  test "removing entities", %{e1: e1, s1: s1, e2: e2} do
    Transport.dispatch(s1, "entity:heroes_ascent", "leave", %{})

    assert_receive %{sender: ^e2, event: {:socket_broadcast, %Message{
      topic: "entity:heroes_ascent",
      event: "entity_removed",
      payload: %{removed: ^e1}}}}
  end
end
