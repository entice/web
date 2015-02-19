defmodule Entice.Web.ClientTest do
  use ExUnit.Case
  alias Entice.Web.Client

  test "default accounts" do
    assert {:ok, _id} = Client.log_in("root@entice.ps", "root")
  end
end
