defmodule Entice.Web.Friend do
  use Entice.Web.Web, :schema

  schema "friends" do
    field       :base_name,      :string
    belongs_to  :account,        Entice.Web.Account
    belongs_to  :friend_account, Entice.Web.Account
    timestamps
  end


  def changeset(friend, params \\ :invalid) do
    friend
    |> cast(params, [:account_id, :friend_account_id, :base_name])
    |> validate_required([:account_id, :friend_account_id, :base_name])
    |> assoc_constraint(:account)
    |> assoc_constraint(:friend_account)
  end
end
