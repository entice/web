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
  def get_bit(n, b) do
    case (n &&& bit_to_int(b)) > 0 do
      true  -> 1
      false -> 0
    end
  end

  @doc """
  Sets a bit at specified position. This doesnt assume anything
  about the binary - if it is to short, it will add zeroes until position is
  in range. Returns the new binary.
  """
  def set_bit(n, b), do: n ||| bit_to_int(b)

  @doc """
  Unsets a bit at specified position. This doesnt assume anything
  about the binary - if it is to short, it will add zeroes until position is
  in range. Returns the new binary.
  """
  def unset_bit(n, b), do: n &&& ~~~bit_to_int(b)

  defp bit_to_int(b), do: 1 <<< (b - 1)
end
