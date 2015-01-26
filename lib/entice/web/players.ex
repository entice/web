defmodule Entice.Web.Players do
  use Entice.Area
  use Entice.Area.Attributes
  alias Entice.Web.Groups
  alias Entice.Area.Entity
  import Entice.Web.Utils

  # Some additional client only attributes:
  defmodule Network, do: defstruct socket: nil


  @doc """
  Prepares a single (i.e. non-grouped, new) player
  """
  def prepare_new_player(map, socket, char) do
    {:ok, id} = prepare_player(map, socket, char, UUID.uuid4())
    Groups.create_for(map, id)
    {:ok, id}
  end


  @doc """
  Prepares a player that already is part of a group.
  You need to create the group separately.
  """
  def prepare_grouped_player(map, socket, char, entity_id, group_id) do
    {:ok, id} = prepare_player(map, socket, char, entity_id)
    Groups.assign_to(map, group_id)
    {:ok, id}
  end


  defp prepare_player(map, socket, char, id) do
    {:ok, eid} = Entity.start(map,id, %{
      Network => %Network{socket: socket},
      Name => %Name{name: char.name},
      Position => %Position{pos: map.spawn},
      Movement => %Movement{goal: map.spawn},
      Appearance => copy_into(%Appearance{}, char),
      SkillBar => %SkillBar{}})
    {:ok, eid}
  end


  def delete_player(map, id) do
    Groups.delete_for(map, id)
    Entity.stop(map, id)
    :ok
  end


  def get_socket(map, id) do
    {:ok, %Network{socket: socket}} = Entity.get_attribute(map, id, Network)
    socket
  end
end
