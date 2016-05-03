defmodule Entice.Web.Invitation do
  use Entice.Web.Web, :schema

  schema "invitations" do
    field :email, :string
    field :key,   :string
    timestamps
  end


  def changeset(invitation, params \\ :invalid) do
    invitation
    |> cast(params, [:email, :key])
    |> validate_required([:email, :key])
    |> unique_constraint(:email)
    |> unique_constraint(:key)
  end
end
