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
      Account.changeset(%Account{}, %{email: "test1@entice.ps", password: "test1"}) |> Repo.insert!,
      Account.changeset(%Account{}, %{email: "test2@entice.ps", password: "test2"}) |> Repo.insert!,
      Account.changeset(%Account{}, %{email: "test3@entice.ps", password: "test3"}) |> Repo.insert!,
      Account.changeset(%Account{}, %{email: "test4@entice.ps", password: "test4"}) |> Repo.insert!,
      Account.changeset(%Account{}, %{email: "test5@entice.ps", password: "test5"}) |> Repo.insert!]

    for acc <- inserts, into: %{}, do: {acc.id, acc}
  end


  def import_characters(%{} = accounts) do
    for {acc_id, acc} <- accounts do
      Character.changeset_char_create(%Character{}, %{account_id: acc_id, name: "#{acc.email} 1"}) |> Repo.insert!
      Character.changeset_char_create(%Character{}, %{account_id: acc_id, name: "#{acc.email} 2"}) |> Repo.insert!
      Character.changeset_char_create(%Character{}, %{account_id: acc_id, name: "#{acc.email} 3"}) |> Repo.insert!
    end
  end


  def import_friends(%{} = accounts) do
    #The characters are named after their account's email + an index,we set base_name to the first char
    for {acc_id1, _acc1} <- accounts, {acc_id2, acc2} <- accounts, acc_id1 != acc_id2,
    do: Friend.changeset(%Friend{}, %{account_id: acc_id1, friend_account_id: acc_id2, base_name: "#{acc2.email} 1"}) |> Repo.insert!
  end
end


Seeds.import
