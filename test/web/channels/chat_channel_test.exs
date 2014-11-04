defmodule EnticeServer.ChatChannelTest do
  use ExUnit.Case
  alias EnticeServer.ChatChannel
  alias UUID
  alias Phoenix.Socket

  test "Join with a valid auth token" do
    auth_token = UUID.uuid1()
    socket = %Socket{pid: self, router: EnticeServer.Router, channel: "chan66"}
    ChatChannel.join(socket, "global", %{auth_token: auth_token})

    assert_received  %Phoenix.Socket.Message{
      channel: "chan66",
      event: "join",
      message: %{content: "joined global chat successfully"},
      topic: nil}
  end

  test "Get kicked with no auth token" do
    socket = %Socket{pid: self, router: EnticeServer.Router, channel: "chan66"}
    assert {:error, socket, :unauthorized} == ChatChannel.join(socket, "nonexisiting_topic", nil)
  end
end
