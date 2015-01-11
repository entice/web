defmodule Entice.Web.AuthTest do
  use ExUnit.Case
  alias Entice.Web.Auth

  test "default accounts" do
    assert {:ok, _id} = Auth.try_log_in("root@entice.ps", "root")
  end
end
