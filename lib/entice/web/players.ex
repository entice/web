defmodule Entice.Web.Players do
  use Entice.Area
  use Entice.Area.Attributes
  alias Entice.Web.Groups
  alias Entice.Area.Entity
  import Entice.Web.Utils

  def prepare_player(map, char) do
    {:ok, id} = Entity.start(map, UUID.uuid4(), %{
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
end
