defmodule Entice.Web.Repo.Migrations.InitInvitiations do
  use Ecto.Migration

  def change do
    create table(:invitations, primary_key: false) do
      add :id,    :binary_id, primary_key: true
      add :email, :string, size: 60, null: false
      add :key,   :string, size: 36, null: false
      timestamps
    end

    create unique_index(:invitations, [:email])
    create unique_index(:invitations, [:key])
  end
end
