defmodule Entice.Web.MovementChannelTest do
  use ExUnit.Case
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Web.MovementChannel
  alias Entice.Web.Account
  alias Entice.Web.Character
  alias Entice.Web.Client
  alias Entice.Web.Token
  alias Entice.Entity
  alias Phoenix.Socket


  test "joining" do
    socket = %Socket{pid: self, router: Entice.Web.Router}
    {:ok, cid} = Client.add(%Account{characters: [%Character{name: "Some Char"}]})
    {:ok, eid, _pid} = Entity.start()
    {:ok, tid} = Token.create_entity_token(cid, %{entity_id: eid, map: HeroesAscent, char: %Character{}})

    MovementChannel.join(
      "movement:heroes_ascent",
      %{"client_id" => cid,
        "entity_token" => tid},
      socket)

    assert_receive {:socket_reply, %Socket.Message{
      topic: nil,
      event: "join:ok",
      payload: %{}}}
  end
end
