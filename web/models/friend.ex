defmodule Entice.Web.Friend do
  use Entice.Web.Web, :model

  schema "friends" do
    belongs_to :account,        Entice.Web.Account
    belongs_to :friend_account, Entice.Web.Account
    timestamps
  end


  def changeset(friend, params \\ :empty) do
    friend
    |> cast(params, ~w(), ~w())
    |> assoc_constraint(:account)
    |> assoc_constraint(:friend_account)
  end
end
