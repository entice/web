defmodule Entice.Web.Repo.Migrations.AddInvitations do
  use Ecto.Migration

  def up do
    execute(
      "CREATE TABLE invitations( \
          id serial PRIMARY KEY, \
          email varchar(60) UNIQUE, \
          key varchar(36) UNIQUE, \
          createdAt timestamp)")
  end

  def down do
    execute("DROP TABLE invitations")
  end
end