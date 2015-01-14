defmodule Entice.Web.ClientsTest do
  use ExUnit.Case
  alias Entice.Web.Clients

  test "default accounts" do
    assert {:ok, _id} = Clients.log_in("root@entice.ps", "root")
  end
end
