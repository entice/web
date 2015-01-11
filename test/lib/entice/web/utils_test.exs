defmodule Entice.Web.UtilsTest do
  use ExUnit.Case
  import Entice.Web.Utils

  defmodule A, do: defstruct a: 1, b: 2, c: 3
  defmodule B, do: defstruct b: 1, c: 2, d: 3

  test "struct copying" do
    assert copy_into(%B{}, %A{}) == %B{b: 2, c: 3, d: 3}
  end
end
