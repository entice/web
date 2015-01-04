defmodule Entice.Web.ChatChannelTest do
  use ExUnit.Case
  alias Entice.Web.ChatChannel
  alias Phoenix.Socket

  test "Join with a valid auth token" do
    auth_token = UUID.uuid4()
    socket = %Socket{pid: self, router: Entice.Web.Router, channel: "chan66"}
    ChatChannel.join(socket, "global", %{auth_token: auth_token})

    assert_received  %Phoenix.Socket.Message{
      channel: "chan66",
      event: "join",
      message: %{content: "joined global chat successfully"},
      topic: nil}
  end

  test "Get kicked with no auth token" do
    socket = %Socket{pid: self, router: Entice.Web.Router, channel: "chan66"}
    assert {:error, socket, :unauthorized} == ChatChannel.join(socket, "nonexisiting_topic", nil)
  end
end
