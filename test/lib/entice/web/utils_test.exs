defmodule Entice.Web.UtilsTest do
  use ExUnit.Case
  import Entice.Web.Utils

  defmodule A, do: defstruct a: 1, b: 2, c: 3
  defmodule B, do: defstruct b: 1, c: 2, d: 3

  test "struct copying" do
    assert copy_into(%B{}, %A{}) == %B{b: 2, c: 3, d: 3}
  end

  test "bit at" do
    assert 1 == bit_at(<<0b00010101>>, 4)
    assert 0 == bit_at(<<0b00010101>>, 1)
  end
end
