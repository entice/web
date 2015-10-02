defmodule Entice.Web.Friend do
  use Ecto.Model

  schema "friends" do
    belongs_to  :account,        Entice.Web.Account
    belongs_to  :friend_account, Entice.Web.Account
  end 
end