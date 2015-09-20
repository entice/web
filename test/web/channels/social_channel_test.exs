defmodule Entice.Web.SocialChannelTest do
  use Entice.Web.ChannelCase
  use Entice.Logic.Area
  alias Entice.Test.Factories


  setup do
    player = Factories.create_player("social", HeroesAscent)
    {:ok, _, socket} = subscribe_and_join(player[:socket], "social:heroes_ascent", %{})
    {:ok, %{socket: socket}}
  end


  test "message all", %{socket: socket} do
    socket |> push("message", %{"text" => "Blubb"})
    assert_broadcast "message", %{sender: _, text: "Blubb"}
  end
end

