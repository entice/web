defmodule Entice.Web.Repo.Migrations.Init do
  use Ecto.Migration

  def up do
    ["CREATE TABLE accounts( \
        id serial primary key, \
        email varchar(60), \
        password varchar(50))",

     "CREATE TABLE characters( \
        id serial primary key, \
        name varchar(30), \
        profession int, \
        campaign int, \
        sex int, \
        height int, \
        skin_color int, \
        hair_color int, \
        hairstyle int, \
        face int, \
        account serial references accounts(id))",

     "INSERT INTO accounts(email, password) \
      VALUES \
        ('root@entice.ps', 'root'), \
        ('test@entice.ps', 'test')"]
  end

  def down do
    ["DROP TABLE accounts",
     "DROP TABLE characters"]
  end
end
