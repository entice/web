defmodule Entice.Web.MovementChannel do
  use Phoenix.Channel
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Logic.Area
  alias Entice.Web.Client
  alias Entice.Web.Group
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



  def handle_in("entity:move", %{
      "pos" => %{"x" => x, "y" => y},
      "goal" => %{"x" => gx, "y" => gy},
      "plane" => plane,
      "movetype" => mtype,
      "speed" => speed}, socket) when mtype in 0..10 and speed in -1..2 do

    #pos upd
    Entity.put_attribute(socket |> area, socket |> entity_id,
      %Position{pos: %Coord{x: x, y: y}})
    # move upd
    Entity.put_attribute(socket |> area, socket |> entity_id,
      %Movement{goal: %Coord{x: gx, y: gy}, plane: plane, movetype: mtype, speed: speed})

    {:ok, socket}
  end



  def leave(_msg, socket) do
    {:ok, socket}
  end
end
