defmodule Entice.Web.Invitation do
  use Entice.Web.Web, :model

  schema "invitations" do
    field :email, :string
    field :key,   :string
    timestamps
  end


  def changeset(invitation, params \\ :empty) do
    invitation
    |> cast(params, ~w(email key), ~w())
    |> unique_constraint(:email)
    |> unique_constraint(:key)
  end
end
