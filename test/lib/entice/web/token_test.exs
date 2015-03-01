defmodule Entice.Web.TokenTest do
  use ExUnit.Case
  use Entice.Logic.Area
  alias Entice.Web.Token
  alias Entice.Test.Factories


  setup do
    player = Factories.create_player("test:token", HeroesAscent)
    {:ok, [client_id: player[:client_id], entity_id: player[:entity_id], character: player[:character]]}
  end


  test "mapchange token", %{client_id: cid, entity_id: eid, character: char} do
    {:ok, token} = Token.create_mapchange_token(cid, %{
      entity_id: eid,
      map: RandomArenas,
      char: char})

    assert {:ok, ^token, :mapchange, %{entity_id: ^eid, map: RandomArenas, char: ^char} = t} = Token.get_token(cid)

    assert %{token: ^token, entity_id: ^eid} = Map.put(t, :token, token)
  end
end
