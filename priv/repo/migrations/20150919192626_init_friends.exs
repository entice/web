defmodule Entice.Web.Repo.Migrations.AddFriends do
  use Ecto.Migration

  def up do
    execute(
      "CREATE TABLE friends( \
          id serial PRIMARY KEY, \
          account_id int REFERENCES accounts, \
          friend_account_id int REFERENCES accounts)")

    execute(
      "INSERT INTO friends (account_id, friend_account_id) \
       VALUES \
       (1, 2), \
       (2, 1) ")
  end

  def down do
    execute("DROP TABLE friends")
  end
end
