defmodule Entice.Web.UtilsTest do
  use ExUnit.Case
  import Entice.Web.Utils

  defmodule A, do: defstruct a: 1, b: 2, c: 3
  defmodule B, do: defstruct b: 1, c: 2, d: 3

  test "struct copying" do
    assert copy_into(%B{}, %A{}) == %B{b: 2, c: 3, d: 3}
  end

  test "bit at" do
    # in range            LSBit---v
    assert 0 == bit_at(<<0b00010101>>, 4)
    assert 1 == bit_at(<<0b00010101>>, 1)
    assert 0 == bit_at(<<0b00010101>>, 8)
    # outta range, mister!
    assert 0 == bit_at(<<0b00010101>>, 9)
    assert 0 == bit_at(<<0b00010101>>, 42)
  end

  test "bit set" do
    # in range
    assert <<0b00001000>> == bit_set(<<0b00000000>>, 4, 1)
    assert <<0b00000000>> == bit_set(<<0b00001000>>, 4, 0)
    assert <<0b01101001>> == bit_set(<<0b01001001>>, 6, 1)
    # outta range
    #assert <<0b101101001>> == bit_set(<<0b01101001>>, 9, 1)
  end
end
