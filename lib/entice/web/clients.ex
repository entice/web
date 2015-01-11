defmodule Entice.Web.Clients do
  use Entice.Area
  alias Entice.Web.Account
  alias Entice.Area.Entity

  # Some additional client only attributes:
  defmodule TransferToken, do: defstruct id: ""

  def exists?(id) do
    Entity.exists?(Lobby, id)
  end

  def add(account) do
    Entity.start(Lobby, UUID.uuid4(), %{Account => account})
  end

  def remove(id) do
    Entity.stop(Lobby, id)
  end

  def get_account(id) do
    Entity.get_attribute(Lobby, id, Account)
  end

  def create_transfer_token(id) do
    tid = UUID.uuid4()
    Entity.put_attribute(Lobby, id, %TransferToken{id: tid})
    {:ok, tid}
  end

  def get_transfer_token(id) do
    {:ok, token} = Entity.get_attribute(Lobby, id, TransferToken)
    {:ok, token.id}
  end

  def delete_transfer_token(id) do
    Entity.remove_attribute(Lobby, id, TransferToken)
  end

  def get_char(id, name) do
    {:ok, %Account{characters: chars}} = get_account(id)
    case chars |> Enum.find(fn c -> c.name == name end) do
      nil -> {:error, :character_not_found}
      char -> {:ok, char}
    end
  end

  def add_char(id, char) do
    {:ok, _acc} = Entity.update_attribute(Lobby, id, Account,
      fn acc -> %Account{acc | characters: [acc.characters|char]} end)
    char
  end
end
