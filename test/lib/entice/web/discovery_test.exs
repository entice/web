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
    Entity.put_attribute(e1, %MapInstance{map: HeroesAscent})
    Discovery.register(e1, HeroesAscent)
    Spy.register(e1, self)

    Entity.put_attribute(e2, %Name{name: "Test2"})
    Entity.put_attribute(e2, %Position{pos: %Coord{x: 2}})
    Entity.put_attribute(e2, %MapInstance{map: HeroesAscent})
    Discovery.register(e2, HeroesAscent)
    Spy.register(e2, self)

    Entice.Web.Endpoint.subscribe(self, "test:discovery")

    {:ok, [e1: e1, e2: e2]}
  end


  test "setup", %{e1: e1, e2: e2} do
    Entice.Web.Endpoint.broadcast("test:discovery", "test", %{test: 1})
    assert_receive {:socket_broadcast, %{topic: "test:discovery", event: "test", payload: %{test: 1}}}

    Entice.Web.Endpoint.entity_broadcast("discovery:heroes_ascent", :test)
    assert_receive %{sender: ^e1, event: :test}, 5000
    assert_receive %{sender: ^e2, event: :test}, 5000
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

    assert_receive %{sender: ^e1, event: {
      :discovery_inactive,
      "test:discovery",
      [Name]}}

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
