defmodule Entice.Web.Utils do
  use Bitwise

  @doc """
  Takes a struct and copies the values of all matching keys
  of a second struct into it.
  """
  def copy_into(%{__struct__: result} = a, %{__struct__: _} = b) do
    struct(result, Dict.merge(Map.from_struct(a), Map.from_struct(b)))
  end

  @doc """
  Returns the bit of a bitstring at postion.
  If the position is not in range of the bitstring, it assumes a value of 0.
  """
  def bit_at(bin, i) when is_binary(bin) and i > 0 and i < bit_size(bin) do
    seek = i - 1
    rest = bit_size(bin) - i
    <<_::size(rest), result::1, _::size(seek)>> = bin
    result
  end

  def bit_at(bin, i) when is_binary(bin) and i > 0, do: 0

  @doc """
  Sets a bit at specified position to true. This doesnt assume anything
  about the binary - if it is to short, it will add zeroes until position is
  in range. Returns the new binary.
  """
  def bit_set(<<0>>, i, value) when i > 0 do
    << value <<< (i - 1) >>
  end

  def bit_set(bin, i, value) when is_binary(bin) and i > 0 and i < bit_size(bin) do
    seek = i - 1
    rest = bit_size(bin) - i
    <<left::size(rest), _::1, right::size(seek)>> = bin
    <<(left <<< i) ||| (value <<< (i-1)) ||| right>>
  end

  def bit_set(bin, i, value) when is_binary(bin) and i > 0 do
    diff = i - bit_size(bin)
    bit_set(<<0>>, diff, value) <> bin
  end
end
