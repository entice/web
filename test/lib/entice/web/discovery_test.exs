defmodule Entice.Logic.DiscoveryTest do
  use ExUnit.Case
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Entity
  alias Entice.Web.Discovery
  alias Entice.Test.Spy


  setup do
    {:ok, e1, _pid} = Entity.start
    {:ok, e2, _pid} = Entity.start

    Entity.put_attribute(e1, %Name{name: "Test1"})
    Entity.put_attribute(e1, %Position{pos: %Coord{x: 1}})
    Discovery.init(e1, HeroesAscent)
    Spy.inject_into(e1, self)

    Entity.put_attribute(e2, %Name{name: "Test2"})
    Entity.put_attribute(e2, %Position{pos: %Coord{x: 2}})
    Discovery.init(e2, HeroesAscent)
    Spy.inject_into(e2, self)

    Entice.Web.Endpoint.subscribe(self, "test:discovery")

    {:ok, [e1: e1, e2: e2]}
  end


  test "setup", %{e1: e1, e2: e2} do
    Entice.Web.Endpoint.entity_broadcast("discovery:heroes_ascent", :test)
    assert_receive %{sender: ^e1, event: :test}, 1000
    assert_receive %{sender: ^e2, event: :test}
  end


  test "going active", %{e1: e1, e2: e2} do
    Discovery.notify_active(e1, "test:discovery", [Name])

    assert_receive %{sender: ^e2, event: {
      :discovery_activated,
      ^e1,
      "test:discovery",
      [Name],
      %{Name => %Name{name: "Test1"}}}}

    assert_receive {:socket_broadcast, %{
      topic: "test:discovery",
      event: "discovered",
      payload: %{
        recipient: ^e1,
        entity_id: ^e2,
        attributes: %{Name => %Name{name: "Test2"}}}}}

    assert_receive {:socket_broadcast, %{
      topic: "test:discovery",
      event: "discovered",
      payload: %{
        recipient: ^e2,
        entity_id: ^e1,
        attributes: %{Name => %Name{name: "Test1"}}}}}
  end


  test "going inactive", %{e1: e1, e2: e2} do
    Discovery.notify_inactive(e1, "test:discovery", [Name])

    assert_receive %{sender: ^e2, event: {
      :discovery_deactivated,
      ^e1,
      "test:discovery",
      [Name]}}

    assert_receive {:socket_broadcast, %{
      topic: "test:discovery",
      event: "undiscovered",
      payload: %{
        recipient: ^e2,
        entity_id: ^e1}}}
  end
end
