defmodule Entice.Web.Invitation do
  use Ecto.Model

  schema "invitations" do
    field :email, :string
    field :key, :string
  end
end