defmodule Entice.Web.GroupChannel do
  use Phoenix.Channel
  use Entice.Logic.Area
  alias Entice.Logic.Area
  alias Entice.Logic.Group
  alias Entice.Web.Client
  import Phoenix.Naming
  import Entice.Web.ChannelHelper


  def join("group:" <> map, %{"client_id" => client_id, "access_token" => token}, socket) do
    {:ok, ^token, :player, %{area: map_mod, entity_id: entity_id, char: char}} = Client.get_token(client_id)
    {:ok, ^map_mod} = Area.get_map(camelize(map))

    socket = socket
      |> set_area(map_mod)
      |> set_entity_id(entity_id)
      |> set_client_id(client_id)
      |> set_character(char)

    :ok = Group.init(entity_id)

    socket |> reply("join:ok", %{})
    {:ok, socket}
  end


  def handle_in("merge", %{"target" => id}, socket) do
    Groups.merge(socket |> area, socket |> entity_id, id)
    {:ok, socket}
  end


  def handle_in("kick", %{"target" => id}, socket) do
    Groups.kick(socket |> area, socket |> entity_id, id)
    {:ok, socket}
  end


  def leave(_msg, socket) do
    Player.delete_player(socket |> area, socket |> entity_id)
    Client.remove_socket(socket |> client_id, socket)
    {:ok, socket}
  end
end
