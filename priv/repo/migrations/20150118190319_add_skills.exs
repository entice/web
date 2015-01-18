defmodule Entice.Web.Repo.Migrations.AddSkills do
  use Ecto.Migration

  def up do
    execute("ALTER TABLE characters ADD available_skills text")
    execute("UPDATE characters SET available_skills = '3FF'")
  end

  def down do
    execute("ALTER TABLE characters DROP available_skills")
  end
end
