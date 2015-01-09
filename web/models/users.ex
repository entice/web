defmodule Entice.Web.Users do
    use Ecto.Model

    schema "users" do
      field :email, :string
      field :password, :string
    end
end
