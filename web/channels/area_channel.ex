defmodule Entice.Web.AreaChannel do
  use Phoenix.Channel
  use Entice.Area
  alias Entice.Area.Entity

  def join(socket, "heroes_ascent", _handshake_msg) do
    {:ok, id} = Entity.start(HeroesAscent, UUID.uuid4())
    socket |> assign(:entity_id, id)
    socket |> reply("join", %{entity_id: id})
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
