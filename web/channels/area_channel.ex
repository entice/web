defmodule Entice.Web.AreaChannel do
  use Phoenix.Channel
  use Entice.Area
  use Entice.Area.Attributes
  alias Entice.Area.Entity

  def join(socket, "heroes_ascent", _handshake_msg) do
    {:ok, id} = Entity.start(HeroesAscent, UUID.uuid4(), %{Name => %Name{name: "Test Char"}})
    socket = socket
    |> assign(:area, HeroesAscent)
    |> assign(:entity_id, id)
    socket |> reply("join", %{entities: Entity.get_entity_dump(HeroesAscent)})
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

  def leave(socket, _msg) do
    Entity.stop(socket.assigns[:area], socket.assigns[:entity_id])
    socket
  end
end
