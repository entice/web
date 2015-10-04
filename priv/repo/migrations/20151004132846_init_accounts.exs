defmodule Entice.Web.Repo.Migrations.InitAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id,       :binary_id, primary_key: true
      add :email,    :string, size: 60, null: false
      add :password, :string, size: 50, null: false
      timestamps
    end

    create unique_index(:accounts, [:email])
  end
end
