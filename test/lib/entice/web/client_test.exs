defmodule Entice.Web.ClientTest do
  use ExUnit.Case
  alias Entice.Skills
  alias Entice.Web.Client

  test "default accounts" do
    assert {:ok, _id} = Client.log_in("root@entice.ps", "root")
  end

  test "default character" do
    assert {:ok, id} = Client.log_in("root@entice.ps", "root")
    assert {:ok, char} = Client.get_char(id, "Test Char")
    assert Skills.max_unlocked_skills == :erlang.list_to_integer(char.available_skills |> String.to_char_list, 16)
  end
end
