defmodule Entice.Web.GroupChannel do
  use Phoenix.Channel
  use Entice.Area
  alias Entice.Area
  alias Entice.Web.Clients
  alias Entice.Web.Groups
  import Phoenix.Naming
  import Entice.Web.ChannelHelper


  def join("group:" <> map, %{"client_id" => client_id, "access_token" => token}, socket) do
    {:ok, ^token, :player, %{area: map_mod, entity_id: entity_id, char: char}} = Clients.get_token(client_id)
    {:ok, ^map_mod} = Area.get_map(camelize(map))

    socket = socket
      |> set_area(map_mod)
      |> set_entity_id(entity_id)
      |> set_client_id(client_id)
      |> set_character(char)

    {:ok, group} = Groups.create_for(map_mod, entity_id)

    socket |> reply("join:ok", %{group: group})
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
    Players.delete_player(socket |> area, socket |> entity_id)
    Clients.remove_socket(socket |> client_id, socket)
    {:ok, socket}
  end
end
