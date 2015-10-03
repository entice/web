defmodule Entice.Web.Repo.Migrations.AddFriends do
  use Ecto.Migration

  def up do
    execute(
      "CREATE TABLE friends( \
          id serial PRIMARY KEY, \
          basename varchar(50), \
          account_id int REFERENCES accounts, \
          friend_account_id int REFERENCES accounts)")

    #TODO: UPDATE THIS TO SELECTS FROM ACCOUNT AND CHARACTER TABLE SO IT UPDATES WITH THEIR CHANGES
    execute(
      "INSERT INTO friends (basename, account_id, friend_account_id) \
       VALUES \
       ('Cool Story', 1, 2), \
       ('Test Char', 2, 1) ")
  end

  def down do
    execute("DROP TABLE friends")
  end
end
