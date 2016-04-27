defmodule Entice.Web.CharacterTest do
  use Entice.Web.ModelCase
  alias Entice.Web.{Account, Character}


  test "initial available skills" do
    acc = Account.changeset(%Account{}, %{email: "hansus@wurstus.com",  password: "hansus_wurstus"})  |> Repo.insert!
    char = Character.changeset_char_create(%Character{}, %{account_id: acc.id, name: "Hansus Wurstus"}) |> Repo.insert!
    assert char.available_skills != ""
  end
end
