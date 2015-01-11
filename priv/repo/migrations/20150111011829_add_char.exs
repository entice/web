defmodule Entice.Web.Repo.Migrations.AddChar do
  use Ecto.Migration

  def up do
    "INSERT INTO characters (name, account_id, profession, campaign, sex, height, skin_color, hair_color, hairstyle, face) \
     VALUES \
      ('Test Char', 1, 1, 0, 1, 0, 3, 0, 7, 30), \
      ('Shit Happens', 1, 1, 0, 1, 0, 3, 0, 7, 30), \
      ('Cool Story', 2, 1, 0, 1, 0, 3, 0, 7, 30)"
  end

  def down do
    "DELETE FROM characters \
     WHERE name = 'Test Char' \
        OR name = 'Shit Happens' \
        OR name = 'Cool Story'"
  end
end
