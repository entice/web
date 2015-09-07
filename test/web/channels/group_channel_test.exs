defmodule Entice.Web.GroupChannelTest do
  use ExUnit.Case
  use Entice.Logic.Area
  alias Entice.Test.Factories
  alias Entice.Test.Factories.Transport
  alias Phoenix.Socket.Message


  setup do
    p = Factories.create_player("group", HeroesAscent)
    t = Factories.create_transport
    :ok = Transport.dispatch_join(t, p[:socket], %{"client_id" => p[:client_id], "entity_token" => p[:token]})

    {:ok, [e: p[:entity_id]]}
  end


  test "join", %{e: e} do
    assert_receive {:socket_push, %Message{
      topic: "group:heroes_ascent",
      event: "phx_reply",
      ref: nil,
      payload: %{
        status: "ok",
        ref: "1",
        response: %{}}}}
    assert_receive {:socket_push, %Message{
      topic: "group:heroes_ascent",
      event: "join:ok",
      payload: %{}}}
  end
end
