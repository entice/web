defmodule Entice.Web.Account do
  use Entice.Web.Web, :model

  schema "accounts" do
    field :email,    :string
    field :password, :string
    has_many :characters, Entice.Web.Character
    has_many :friends,    Entice.Web.Friend
    timestamps
  end


  def changeset(account, params \\ :empty) do
    account
    |> cast(params, ~w(email password), ~w())
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
