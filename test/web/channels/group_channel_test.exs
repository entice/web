defmodule Entice.Web.GroupChannelTest do
  use Entice.Web.ChannelCase
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Web.Endpoint
  alias Entice.Entity
  alias Entice.Test.Factories


  setup do
    player = Factories.create_player("group", HeroesAscent)
    {:ok, _, socket} = subscribe_and_join(player[:socket], "group:heroes_ascent", %{})
    {:ok, [player: player, socket: socket]}
  end


  test "join" do
    assert_push "join:ok", %{}
  end


  # this should actually be tested together with the entity_channel reacting to a map change request
  test "mapchange", %{player: player, socket: socket} do
    new_map = TeamArenas.underscore_name
    # we fake a uuid and subscribe ourselfs to its topic
    eid = UUID.uuid4()
    Endpoint.subscribe(self, Entice.Web.Socket.id_by_entity(eid))
    # set the faked entity as a member
    player[:entity_id] |> Entity.put_attribute(%Leader{members: [eid]})
    # trigger the mapchange
    send socket.channel_pid, {:entity_mapchange, %{map: new_map}}
    # we expect to be notified
    assert_receive {:leader_mapchange, %{map: ^new_map}}
  end
end
