defmodule Entice.Web.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    ["CREATE TABLE users( \
        id serial primary key, \
        email varchar(60), \
        password varchar(50))",

     "INSERT INTO users(email, password) \
      VALUES \
        ('root@entice.ps', 'root'), \
        ('test@entice.ps', 'test')"]
  end

  def down do
    "DROP TABLE users"
  end
end
