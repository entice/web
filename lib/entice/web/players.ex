defmodule Entice.Web.Players do
  use Entice.Area
  use Entice.Area.Attributes
  alias Entice.Web.Groups
  alias Entice.Area.Entity
  import Entice.Web.Utils

  # Some additional client only attributes:
  defmodule Network, do: defstruct socket: nil


  def prepare_player(map, socket, char) do
    {:ok, id} = Entity.start(map, UUID.uuid4(), %{
      Network => %Network{socket: socket},
      Name => %Name{name: char.name},
      Position => %Position{pos: map.spawn},
      Movement => %Movement{goal: map.spawn},
      Appearance => copy_into(%Appearance{}, char),
      SkillBar => %SkillBar{}})
    Groups.create_for(map, id)
    {:ok, id}
  end


  def delete_player(map, id) do
    Groups.delete_for(map, id)
    Entity.stop(map, id)
    :ok
  end


  def get_socket(map, id) do
    {:ok, %Network{socket: socket}} = Entity.get_attribute(map, id, Network)
    {:ok, socket}
  end
end
