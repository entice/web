defmodule Entice.Web.AreaEventBridgeTest do
  use ExUnit.Case
  alias Phoenix.Channel
  alias Phoenix.Socket
  alias Entice.Area.Entity

  test "join and get a dump of the area state" do
    socket = %Socket{pid: self, router: Entice.Web.Router, channel: "area"}
    socket = socket |> Channel.subscribe("area", "heroes_ascent")

    # now add an entity...
    Entity.start(Entice.Area.HeroesAscent, UUID.uuid4(), %{})

    assert_receive %Phoenix.Socket.Message{
      channel: "area",
      topic: "heroes_ascent",
      event: "entity:add",
      message: %{entity_id: _}
    }
  end
end
