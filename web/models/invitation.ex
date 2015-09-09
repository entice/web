defmodule Entice.Web.Invitation do
  use Ecto.Model

  schema "invitations" do
    field :email, :string
    field :key, :string
    field :createdat, Ecto.DateTime, default: Ecto.DateTime.local
  end
end