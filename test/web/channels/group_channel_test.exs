defmodule Entice.Web.GroupChannelTest do
  use ExUnit.Case
  use Entice.Logic.Area
  alias Entice.Entity
  alias Entice.Web.GroupChannel
  alias Entice.Web.Account
  alias Entice.Web.Character
  alias Entice.Web.Client
  alias Entice.Web.Token
  alias Entice.Web.Player
  alias Phoenix.Socket


  # TODO: dont rely on shared maps in tests, it fucks up the expected values


  test "join and get a group assigned" do
    socket = %Socket{pid: self, router: Entice.Web.Router}
    acc = %Account{characters: [%Character{name: "Some Char"}]}
    {:ok, cid} = Client.add(acc)
    {:ok, eid, _pid} = Entity.start()
    {:ok, tid} = Token.create_entity_token(cid, %{entity_id: eid, area: RandomArenas, char: acc.characters |> hd})
    Player.init(eid, RandomArenas, acc.characters |> hd)

    GroupChannel.join(
      "group:random_arenas",
      %{"client_id" => cid,
        "entity_token" => tid},
      socket)

    assert_receive {:socket_reply, %Socket.Message{
      topic: nil,
      event: "join:ok",
      payload: %{}}}
  end
end
