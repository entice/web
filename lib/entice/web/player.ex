defmodule Entice.Web.Player do
  use Entice.Logic.Attributes
  alias Entice.Entity
  import Entice.Utils.StructOps


  @doc """
  Prepares a single, simple player
  """
  def init(map, char) do
    {:ok, eid, _pid} = Entity.start(UUID.uuid4(), %{
      Name => %Name{name: char.name},
      Position => %Position{pos: map.spawn},
      Movement => %Movement{goal: map.spawn},
      Appearance => copy_into(%Appearance{}, char),
      SkillBar => %SkillBar{}})
    {:ok, eid}
  end


  def stop(id), do: Entity.stop(id)
end
