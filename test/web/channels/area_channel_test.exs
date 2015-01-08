defmodule Entice.Web.AreaChannelTest do
  use ExUnit.Case
  alias Entice.Web.AreaChannel
  alias Phoenix.Socket

  test "join and get a dump of the area state" do
    socket = %Socket{pid: self, router: Entice.Web.Router}
    AreaChannel.join("area:heroes_ascent", %{}, socket)

    assert_received  {:socket_reply, %Phoenix.Socket.Message{
      topic: "area:heroes_ascent",
      event: "join:ok",
      payload: %{entity: _, entities: _}
    }}
  end
end
