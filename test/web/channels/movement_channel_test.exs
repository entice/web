defmodule Entice.Web.MovementChannelTest do
  use ExUnit.Case
  use Entice.Logic.Area
  alias Entice.Test.Factories
  alias Entice.Test.Spy
  alias Phoenix.Socket.Message
  alias Phoenix.Channel.Transport


  setup do
    p1 = Factories.create_player("movement", HeroesAscent, true)
    Spy.register(p1[:entity_id], self)

    assert {:ok, _sock} = Transport.dispatch(p1[:socket], "movement:heroes_ascent", "join", %{"client_id" => p1[:client_id], "entity_token" => p1[:token]})

    {:ok, [e1: p1[:entity_id]]}
  end


  test "join", %{e1: e1} do
    assert_receive %{sender: ^e1, event: {:socket_reply, %Message{
      topic: "movement:heroes_ascent",
      event: "join:ok",
      payload: %{}}}}
  end
end
