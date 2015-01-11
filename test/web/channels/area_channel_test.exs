defmodule Entice.Web.AreaChannelTest do
  use ExUnit.Case
  use Entice.Area.Attributes
  alias Entice.Web.AreaChannel
  alias Entice.Web.Account
  alias Entice.Web.Character
  alias Entice.Web.Clients
  alias Phoenix.Socket

  test "join and get a dump of the area state" do
    socket = %Socket{pid: self, router: Entice.Web.Router}
    {:ok, cid} = Clients.add(%Account{characters: [%Character{name: "Some Char"}]})
    {:ok, tid} = Clients.create_transfer_token(cid)

    AreaChannel.join(
      "area:heroes_ascent",
      %{"client_id" => cid,
        "transfer_token" => tid,
        "char_name" => "Some Char"},
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
