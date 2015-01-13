defmodule Entice.Web.Utils do

  @doc """
  Takes a struct and copies the values of all matching keys
  of a second struct into it.
  """
  def copy_into(%{__struct__: result} = a, %{__struct__: _} = b) do
    struct(result, Dict.merge(Map.from_struct(a), Map.from_struct(b)))
  end

  @doc """
  Returns the bit of a bitstring at postion.
  """
  def bit_at(bin, i) when is_binary(bin) and i > 0 and i < bit_size(bin) do
    seek = i - 1
    rest = bit_size(bin) - i
    <<_::size(seek), result::1, _::size(rest)>> = bin
    result
  end
end
