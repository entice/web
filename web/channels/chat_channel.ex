defmodule Entice.Web.ChatChannel do
  use Phoenix.Channel

  def join(socket, "global", %{auth_token: token}) do
    reply socket, "join", %{content: "joined global chat successfully"}
    {:ok, socket}
  end

  def join(socket, _, _) do
    {:error, socket, :unauthorized}
  end

  def event(socket, "user:active", %{user_id: user_id}) do
    socket.conn
  end

  def event(socket, "user:idle", %{user_id: user_id}) do
    socket
  end
end
