defmodule Entice.Web.Repo.Migrations.InitFriends do
  use Ecto.Migration

  def change do
    create table(:friends, primary_key: false) do
      add :id,                :binary_id, primary_key: true
      add :base_name,         :string, size: 60
      add :account_id,        references(:accounts, type: :binary_id)
      add :friend_account_id, references(:accounts, type: :binary_id)
      timestamps
    end
  end
end
