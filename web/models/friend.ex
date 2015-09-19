defmodule Entice.Web.Friend do
  use Ecto.Model

  #has_one :friend_account_id because the 
  #friend account can be deleted before the 
  #friend object itself
  schema "friends" do
    belongs_to  :account_id,            Entice.Web.Account
    has_one     :friend_account_id,     Entice.Web.Account
  end 
end
