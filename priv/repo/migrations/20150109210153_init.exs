defmodule Entice.Web.Repo.Migrations.Init do
  use Ecto.Migration

  def up do
    execute(
      "CREATE TABLE accounts( \
          id serial PRIMARY KEY, \
          email varchar(60) UNIQUE, \
          password varchar(50))")

    execute(
      "CREATE TABLE characters( \
        id serial PRIMARY KEY, \
        name varchar(30) UNIQUE, \
        profession int, \
        campaign int, \
        sex int, \
        height int, \
        skin_color int, \
        hair_color int, \
        hairstyle int, \
        face int, \
        account_id int REFERENCES accounts)")

    execute(
     "INSERT INTO accounts(email, password) \
      VALUES \
        ('root@entice.ps', 'root'), \
        ('test@entice.ps', 'test')")
  end

  def down do
    execute("DROP TABLE accounts")
    execute("DROP TABLE characters")
  end
end
