defmodule Entice.Web.Utils do

  @doc """
  Takes a struct and copies the values of all matching keys
  of a second struct into it.
  """
  def copy_into(%{__struct__: result} = a, %{__struct__: _} = b) do
    struct(result, Dict.merge(Map.from_struct(a), Map.from_struct(b)))
  end
end
