defmodule Entice.Web.Repo.Migrations.AddChar do
  use Ecto.Migration

  def up do
    execute(
      "INSERT INTO characters (name, profession, campaign, sex, height, skin_color, hair_color, hairstyle, face, account_id) \
       VALUES \
        ('Test Char', 1, 0, 1, 0, 3, 0, 7, 30,    (SELECT id FROM accounts WHERE email = 'root@entice.ps')), \
        ('Shit Happens', 1, 0, 1, 0, 3, 0, 7, 30, (SELECT id FROM accounts WHERE email = 'root@entice.ps')), \
        ('Cool Story', 1, 0, 1, 0, 3, 0, 7, 30,   (SELECT id FROM accounts WHERE email = 'test@entice.ps'))")
  end

  def down do
    execute(
      "DELETE FROM characters \
       WHERE name = 'Test Char' \
          OR name = 'Shit Happens' \
          OR name = 'Cool Story'")
  end
end
