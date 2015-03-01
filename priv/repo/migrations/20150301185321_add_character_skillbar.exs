defmodule Entice.Web.Repo.Migrations.AddCharacterSkillbar do
  use Ecto.Migration

  def up do
    execute("ALTER TABLE characters ADD skillbar int[]")
    execute("UPDATE characters SET skillbar = '{0, 0, 0, 0, 0, 0, 0, 0}'")
  end

  def down do
    execute("ALTER TABLE characters DROP skillbar")
  end
end
