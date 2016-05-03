defmodule Entice.Web.Account do
  use Entice.Web.Web, :schema

  schema "accounts" do
    field :email,    :string
    field :password, :string
    has_many :characters, Entice.Web.Character
    has_many :friends,    Entice.Web.Friend
    timestamps
  end


  def changeset(account, params \\ :invalid) do
    account
    |> cast(params, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
