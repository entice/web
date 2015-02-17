defmodule Entice.Web.SkillChannelTest do
  use ExUnit.Case
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Web.SkillChannel
  alias Entice.Web.Account
  alias Entice.Web.Character
  alias Entice.Web.Client
  alias Entice.Web.Token
  alias Entice.Entity
  alias Phoenix.Socket


  test "joining" do
    socket = %Socket{pid: self, router: Entice.Web.Router}
    {:ok, cid, _pid} = Client.add(%Account{characters: [%Character{name: "Some Char"}]})
    {:ok, eid, _pid} = Entity.start()
    {:ok, tid} = Token.create_entity_token(cid, %{entity_id: eid, area: HeroesAscent, char: %Character{}})

    SkillChannel.join(
      "skill:heroes_ascent",
      %{"client_id" => cid,
        "entity_token" => tid},
      socket)

    assert_receive {:socket_reply, %Socket.Message{
      topic: nil,
      event: "join:ok",
      payload: %{
        unlocked_skills: _,
        skillbar: _}}}
  end
end
