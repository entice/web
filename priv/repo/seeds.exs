# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Entice.Web.Repo.insert!(%SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

defmodule Seeds do
  alias Entice.Web.Repo
  alias Entice.Web.Account
  alias Entice.Web.Character
  alias Entice.Web.Friend


  def import do
    accs = import_accounts
    import_characters(accs)
    import_friends(accs)
  end


  def import_accounts do
    inserts = [
      Account.changeset(%Account{}, %{email: "root@entice.ps",  password: "root"})  |> Repo.insert!,
      Account.changeset(%Account{}, %{email: "test@entice.ps",  password: "test"})  |> Repo.insert!,
      Account.changeset(%Account{}, %{email: "testA@entice.ps", password: "testA"}) |> Repo.insert!,
      Account.changeset(%Account{}, %{email: "testB@entice.ps", password: "testB"}) |> Repo.insert!,
      Account.changeset(%Account{}, %{email: "testC@entice.ps", password: "testC"}) |> Repo.insert!,
      Account.changeset(%Account{}, %{email: "testD@entice.ps", password: "testD"}) |> Repo.insert!,
      Account.changeset(%Account{}, %{email: "testE@entice.ps", password: "testE"}) |> Repo.insert!]

    for acc <- inserts, into: %{}, do: {acc.id, acc}
  end


  def import_characters(%{} = accounts) do
    for {acc_id, acc} <- accounts do
      name = acc.email |> String.split("@") |> hd() |> String.capitalize()
      Character.changeset_char_create(%Character{}, %{account_id: acc_id, name: "#{name} #{name} A"}) |> Repo.insert!
      Character.changeset_char_create(%Character{}, %{account_id: acc_id, name: "#{name} #{name} B"}) |> Repo.insert!
      Character.changeset_char_create(%Character{}, %{account_id: acc_id, name: "#{name} #{name} C"}) |> Repo.insert!
    end
  end


  def import_friends(%{} = accounts) do
    #The characters are named after their account's email + an index,we set base_name to the first char
    for {acc_id1, _acc1} <- accounts, {acc_id2, acc2} <- accounts, acc_id1 != acc_id2 do
      name = acc2.email |> String.split("@") |> hd() |> String.capitalize()
      Friend.changeset(%Friend{}, %{account_id: acc_id1, friend_account_id: acc_id2, base_name: "#{name} #{name} A"}) |> Repo.insert!
    end
  end
end


Seeds.import
