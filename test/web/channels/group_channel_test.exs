defmodule Entice.Web.GroupChannelTest do
  use Entice.Web.ChannelCase
  use Entice.Logic.{Maps, Attributes}
  alias Entice.Web.Endpoint
  alias Entice.Entity
  alias Entice.Test.Factories


  setup do
    player = Factories.create_player(HeroesAscent)
    {:ok, _, socket} = subscribe_and_join(player[:socket], "group:heroes_ascent", %{})
    {:ok, [socket: socket, entity_id: player[:entity_id]]}
  end


  # this should actually be tested together with the entity_channel reacting to a map change request
  test "mapchange", %{socket: socket, entity_id: entity_id} do
    new_map = TeamArenas.underscore_name
    # we fake a uuid and subscribe ourselfs to its topic
    eid = UUID.uuid4()
    Endpoint.subscribe(Entice.Web.Socket.id_by_entity(eid))
    # set the faked entity as a member
    entity_id |> Entity.put_attribute(%Leader{members: [eid]})
    # trigger the mapchange
    send socket.channel_pid, {:entity_mapchange, %{map: new_map}}
    # we expect to be notified
    assert_receive {:leader_mapchange, %{map: ^new_map}}
  end
end
