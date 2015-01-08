defmodule Entice.Web.ChatChannel do
  use Phoenix.Channel

  def join("chat:" <> chat_channel, _handshake_msg, socket) do
    socket |> reply("join:ok", %{})
    {:ok, socket}
  end

  def handle_in(socket, "message", %{text: text} = msg) do
    broadcast(socket, "message", msg)
  end
end
