defmodule Entice.Web.AreaChannelTest do
  use ExUnit.Case
  alias Entice.Web.AreaChannel
  alias Phoenix.Socket
  alias Entice.Area.Entity

  test "join and get a dump of the area state" do
    socket = %Socket{pid: self, router: Entice.Web.Router, channel: "area"}
    AreaChannel.join(socket, "heroes_ascent", %{})

    assert_received  %Phoenix.Socket.Message{
      channel: "area",
      topic: "heroes_ascent",
      event: "join:ok",
      message: %{entity: _, entities: _}
    }
  end
end
