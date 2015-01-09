defmodule Entice.Web.AuthTest do
  use ExUnit.Case
  alias Entice.Web.Auth

  test "default accounts" do
    assert Auth.is_valid?("root@entice.ps", "root") == true
  end
end
