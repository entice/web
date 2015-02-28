defmodule Entice.Logic.ObserverTest do
  use ExUnit.Case
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Entity
  alias Entice.Web.Observer
  alias Entice.Test.Spy


  setup do
    {:ok, eid, _pid} = Entity.start

    Entity.put_attribute(eid, %Name{name: "Test1"})
    Observer.init(eid)
    Spy.inject_into(eid, self)

    Entice.Web.Endpoint.subscribe(self, "test:observer")

    {:ok, [entity_id: eid]}
  end


  test "enable sufficient", %{entity_id: eid} do
    Entity.put_attribute(eid, %Position{})

    Observer.notify_active(eid, "test:observer", [Name, Position])

    assert_receive %{sender: ^eid, event: {
      :observer_active,
      "test:observer",
      [Name, Position]}}

    assert_receive {:socket_broadcast, %{
      topic: "test:observer",
      event: "observed",
      payload: %{
        entity_id: ^eid,
        attributes: %{
          Name => %Name{name: "Test1"},
          Position => %Position{}}}}}
  end


  test "change", %{entity_id: eid} do
    Entity.put_attribute(eid, %Position{})

    Observer.notify_active(eid, "test:observer", [Name, Position])

    Entity.update_attribute(eid, Position, fn pos -> %Position{pos | pos: %Coord{x: 1337}} end)

    assert_receive {:socket_broadcast, %{
      topic: "test:observer",
      event: "observed",
      payload: %{
        entity_id: ^eid,
        attributes: %{
          Name => %Name{name: "Test1"},
          Position => %Position{pos: %Coord{x: 1337}}}}}}
  end


  test "change insufficient to sufficient", %{entity_id: eid} do
    Observer.notify_active(eid, "test:observer", [Name, Position])

    assert_receive %{sender: ^eid, event: {
      :observer_active,
      "test:observer",
      [Name, Position]}}

    refute_receive {:socket_broadcast, %{
      topic: "test:observer",
      event: "observed",
      payload: _}}

    Entity.put_attribute(eid, %Position{})

    assert_receive {:socket_broadcast, %{
      topic: "test:observer",
      event: "observed",
      payload: %{
        entity_id: ^eid,
        attributes: %{
          Name => %Name{name: "Test1"},
          Position => %Position{}}}}}
  end


  test "report missing", %{entity_id: eid} do
    Entity.put_attribute(eid, %Position{})

    Observer.notify_active(eid, "test:observer", [Name, Position])

    Entity.remove_attribute(eid, Position)

    assert_receive {:socket_broadcast, %{
      topic: "test:observer",
      event: "missed",
      payload: %{
        entity_id: ^eid,
        attributes: [Position]}}}
  end


  test "disable", %{entity_id: eid} do
    Entity.put_attribute(eid, %Position{})

    Observer.notify_inactive(eid, "test:observer")

    Entity.update_attribute(eid, Position, fn pos -> %Position{pos | pos: %Coord{x: 1337}} end)

    refute_receive {:socket_broadcast, %{
      topic: "test:observer",
      event: "observed",
      payload: _}}
  end
end
