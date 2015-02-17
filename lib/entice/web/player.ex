defmodule Entice.Web.Player do
  use Entice.Logic.Attributes
  alias Entice.Entity
  import Entice.Utils.StructOps


  @doc """
  Prepares a single, simple player
  """
  def init(entity_id, map, char) do
    entity_id |> Entity.put_attribute(%Name{name: char.name})
    entity_id |> Entity.put_attribute(%Position{pos: map.spawn})
    entity_id |> Entity.put_attribute(copy_into(%Appearance{}, char))
  end


  def remove(entity_id) do
    entity_id |> Entity.remove_attribute(Name)
    entity_id |> Entity.remove_attribute(Position)
    entity_id |> Entity.remove_attribute(Appearance)
  end
end
