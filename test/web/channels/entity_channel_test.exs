defmodule Entice.Web.EntityChannelTest do
  use ExUnit.Case
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Web.EntityChannel
  alias Entice.Web.Account
  alias Entice.Web.Character
  alias Entice.Web.Client
  alias Entice.Web.Player
  alias Entice.Entity
  alias Phoenix.PubSub
  alias Phoenix.Socket


  test "join and get a dump of the area state" do
    socket = %Socket{pid: self, router: Entice.Web.Router}
    {:ok, cid, _pid} = Client.add(%Account{characters: [%Character{name: "Some Char"}]})
    {:ok, tid} = Client.create_token(cid, :player, %{area: HeroesAscent, char: %Character{}})

    EntityChannel.join(
      "entity:heroes_ascent",
      %{"client_id" => cid,
        "player_token" => tid},
      socket)

    assert_receive {:socket_reply, %Phoenix.Socket.Message{
      topic: nil,
      event: "join:ok",
      payload: %{
        entity: _,
        entities: _
      }}}
  end
end
