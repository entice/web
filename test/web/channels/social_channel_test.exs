defmodule Entice.Web.SocialChannelTest do
  use Entice.Web.ChannelCase
  use Entice.Logic.Area
  alias Entice.Logic.Group
  alias Entice.Test.Factories


  setup do
    player = Factories.create_player(HeroesAscent)
    {:ok, %{socket: player[:socket], entity_id: player[:entity_id]}}
  end


  test "message all", %{socket: socket} do
    {:ok, _, socket} = subscribe_and_join(socket, "social:heroes_ascent", %{})
    socket |> push("message", %{"text" => "Blubb"})
    assert_broadcast "message", %{sender: _, text: "Blubb"}
  end

  test "group join", %{socket: socket, entity_id: eid} do
    %{entity_id: e1} = Factories.create_player(HeroesAscent)
    Group.register(e1)
    Group.register(eid)
    # prepare the group...
    eid |> Group.new_leader(e1)
    assert eid |> Group.is_my_leader?(e1)

    # join chat
    {:ok, _, socket} = subscribe_and_join(socket, "social:heroes_ascent:group:#{e1}", %{})
    socket |> push("message", %{"text" => "Blubb"})
    assert_broadcast "message", %{sender: _, text: "Blubb"}
    Process.monitor socket.channel_pid

    # get kicked when leader is not leader anymore
    eid |> Group.new_leader(eid)
    assert not (eid |> Group.is_my_leader?(e1))
    # the channel should be dead
    # this should work, but doesn't: assert_push "phx_close", %{}, 5000
    assert_receive {:DOWN, _, _, _, _}
  end
end

