defmodule Entice.Web.SkillChannel do
  use Phoenix.Channel
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Logic.Area
  alias Entice.Web.Client
  alias Entice.Web.Group
  import Phoenix.Naming
  import Entice.Web.ChannelHelper


  def join("skill:" <> map, %{"client_id" => client_id, "access_token" => token}, socket) do
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


  def handle_in("skillbar:set", %{"slot" => slot, "id" => id}, socket) when slot in 0..10 and id > 0 do
    # replace with a sophisticated check of the client's skills
    {:ok, skill} = Skills.get_skill(id)
    Entity.update_attribute(socket |> area, socket |> entity_id,
      SkillBar, fn s -> %SkillBar{slots: Map.put(s.slots, slot, skill)} end)
    {:ok, socket}
  end


  def handle_in("skillbar:set", %{"slot" => slot, "id" => 0}, socket) when slot in 0..10 do
    Entity.update_attribute(socket |> area, socket |> entity_id,
      SkillBar, fn s -> %SkillBar{slots: Map.delete(s.slots, slot)} end)
    {:ok, socket}
  end


  def leave(_msg, socket) do
    {:ok, socket}
  end
end
