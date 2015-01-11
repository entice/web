defmodule Entice.Web.AreaEventBridgeTest do
  use ExUnit.Case
  alias Phoenix.PubSub
  alias Phoenix.Socket
  alias Entice.Area.Entity

  test "propagation of entity creations" do
    PubSub.subscribe(self, "area:heroes_ascent")

    # now add an entity...
    Entity.start(Entice.Area.HeroesAscent, UUID.uuid4(), %{})

    assert_receive {:socket_broadcast, %Phoenix.Socket.Message{
      topic: "area:heroes_ascent",
      event: "entity:add",
      payload: %{entity_id: _}
    }}
  end
end
