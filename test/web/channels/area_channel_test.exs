defmodule Entice.Web.AreaChannelTest do
  use ExUnit.Case
  use Entice.Area
  use Entice.Area.Attributes
  alias Entice.Web.AreaChannel
  alias Entice.Web.Account
  alias Entice.Web.Character
  alias Entice.Web.Clients
  alias Entice.Web.Players
  alias Entice.Web.Groups
  alias Entice.Area.Entity
  alias Phoenix.PubSub
  alias Phoenix.Socket


  test "join and get a dump of the area state" do
    socket = %Socket{pid: self, router: Entice.Web.Router}
    {:ok, cid} = Clients.add(%Account{characters: [%Character{name: "Some Char"}]})
    {:ok, tid} = Clients.create_transfer_token(cid, :area, %{area: HeroesAscent, char: %Character{}})

    AreaChannel.join(
      "area:heroes_ascent",
      %{"client_id" => cid,
        "transfer_token" => tid},
      socket)

    assert_receive {:socket_reply, %Phoenix.Socket.Message{
      topic: nil,
      event: "join:ok",
      payload: %{
        entity: _,
        entities: _
      }}}
  end


  test "change the map, single" do
    # client logs in
    acc = %Account{characters: [%Character{name: "Some Char"}]}
    {:ok, cid} = Clients.add(acc)
    # player connects & joins
    socket = %Socket{pid: self, router: Entice.Web.Router, topic: "area:heroes_ascent", authorized: true}

    PubSub.subscribe(self, "area:heroes_ascent")
    PubSub.subscribe(self, "area:random_arenas")

    {:ok, eid} = Players.prepare_new_player(HeroesAscent, socket, acc.characters |> hd)
    socket = %Socket{socket | assigns:
      socket.assigns
      |> Map.put(:area, HeroesAscent)
      |> Map.put(:entity_id, eid)
      |> Map.put(:client_id, cid)
      |> Map.put(:character, acc.characters |> hd)}

    assert_receive {:socket_broadcast, %Phoenix.Socket.Message{event: "entity:add"}} # Us
    assert_receive {:socket_broadcast, %Phoenix.Socket.Message{event: "entity:add"}} # Our group
    assert_receive {:socket_broadcast, %Phoenix.Socket.Message{event: "entity:attribute:update"}}

    # Now change to another map

    AreaChannel.handle_in("area:change", %{"map" => "random_arenas"}, socket)

    assert_receive {:socket_reply, %Phoenix.Socket.Message{
      topic: "area:heroes_ascent",
      event: "area:change:ok",
      payload: %{
        client_id: ^cid,
        transfer_token: _}}}
  end


  # TODO crappy test is crappy...
  test "change the map, group" do
    # client logs in
    acc = %Account{characters: [%Character{name: "Some Char"}]}
    {:ok, cid} = Clients.add(acc)
    # player connects & joins
    socket1 = %Socket{pid: self, router: Entice.Web.Router, topic: "area:heroes_ascent", authorized: true}
    socket2 = %Socket{pid: self, router: Entice.Web.Router, topic: "area:heroes_ascent", authorized: true}

    PubSub.subscribe(self, "area:heroes_ascent")
    PubSub.subscribe(self, "area:random_arenas")

    # prep players

    {:ok, eid1} = Players.prepare_new_player(HeroesAscent, socket1, acc.characters |> hd)
    socket1 = %Socket{socket1 | assigns:
      socket1.assigns
      |> Map.put(:area, HeroesAscent)
      |> Map.put(:entity_id, eid1)
      |> Map.put(:client_id, cid)
      |> Map.put(:character, acc.characters |> hd)}

    assert_receive {:socket_broadcast, %Phoenix.Socket.Message{event: "entity:add"}} # Us
    assert_receive {:socket_broadcast, %Phoenix.Socket.Message{event: "entity:add"}} # Our group
    assert_receive {:socket_broadcast, %Phoenix.Socket.Message{event: "entity:attribute:update"}}

    {:ok, eid2} = Players.prepare_new_player(HeroesAscent, socket2, acc.characters |> hd)
    socket2 = %Socket{socket2 | assigns:
      socket2.assigns
      |> Map.put(:area, HeroesAscent)
      |> Map.put(:entity_id, eid2)
      |> Map.put(:client_id, cid)
      |> Map.put(:character, acc.characters |> hd)}

    assert_receive {:socket_broadcast, %Phoenix.Socket.Message{event: "entity:add"}} # Us
    assert_receive {:socket_broadcast, %Phoenix.Socket.Message{event: "entity:add"}} # Our group
    assert_receive {:socket_broadcast, %Phoenix.Socket.Message{event: "entity:attribute:update"}}

    # Group them

    Groups.merge(HeroesAscent, eid1, eid2)
    Groups.merge(HeroesAscent, eid2, eid1)

    # Now change to another map

    AreaChannel.handle_in("area:change", %{"map" => "random_arenas"}, socket1)

    timeout = 3000
    res = receive do
      {:socket_broadcast, %Phoenix.Socket.Message{
        topic: "area:heroes_ascent",
        event: "area:change:pre",
        payload: %{
          old_entity_id: _,
          new_entity_id: _,
          group_id: _,
          map: RandomArenas} = msg}} -> msg
    after
      timeout -> assert false
    end

    AreaChannel.handle_out("area:change:pre", res, socket1)

    assert_receive {:socket_reply, %Phoenix.Socket.Message{
      topic: "area:heroes_ascent",
      event: "area:change:force",
      payload: %{
        client_id: _,
        transfer_token: _,
        map: "random_arenas"}}}
  end
end
