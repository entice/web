defmodule Entice.Web.Repo.Migrations.InitCharacters do
  use Ecto.Migration

  def change do
    create table(:characters, primary_key: false) do
      add :id,               :binary_id, primary_key: true
      add :name,             :string, size: 30, null: false

      add :available_skills, :string, default: "0"
      add :skillbar,        {:array, :integer}, default: []

      # appearance values:
      add :profession,       :integer
      add :campaign,         :integer
      add :sex,              :integer
      add :height,           :integer
      add :skin_color,       :integer
      add :hair_color,       :integer
      add :hairstyle,        :integer
      add :face,             :integer

      add :account_id,       references(:accounts, type: :binary_id)

      timestamps
    end

    create unique_index(:characters, [:name])
  end
end
