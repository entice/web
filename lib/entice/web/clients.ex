defmodule Entice.Web.Clients do
  use Entice.Area
  alias Entice.Web.Account
  alias Entice.Area.Entity
  alias Phoenix.Socket
  import Entice.Web.Queries

  # Some additional client only attributes:
  defmodule TransferToken, do: defstruct id: "", type: :simple, payload: %{}

  defmodule Sockets, do: defstruct sockets: %{}


  def exists?(id) do
    Entity.exists?(Lobby, id)
  end


  def log_in(email, password), do: log_in(get_account(email, password))
  defp log_in({:error, _msg}), do: :error
  defp log_in({:ok, acc}),     do: add(acc)


  def add(account) do
    existing =
      Entity.get_entity_dump(Lobby)
      |> Enum.find(fn %{attributes: %{Account => acc}} -> account.email == acc.email end)

    case existing do
      %{id: id} -> {:ok, id}
      nil -> Entity.start(Lobby, UUID.uuid4(), %{
        Account => account,
        Sockets => %Sockets{}})
    end
  end


  def log_out(id), do: remove(id)


  def remove(id) do
    Entity.stop(Lobby, id)
  end


  def get_account(id) do
    Entity.get_attribute(Lobby, id, Account)
  end


  # Transfer token api


  def create_transfer_token(id, type \\ :simple, payload \\ %{}) do
    tid = UUID.uuid4()
    Entity.put_attribute(Lobby, id, %TransferToken{id: tid, type: type, payload: payload})
    {:ok, tid}
  end


  def get_transfer_token(id) do
    {:ok, token} = Entity.get_attribute(Lobby, id, TransferToken)
    {:ok, token.id, token.type, token.payload}
  end


  def delete_transfer_token(id) do
    Entity.remove_attribute(Lobby, id, TransferToken)
  end


  # Chars api


  def get_char(id, name) do
    {:ok, %Account{characters: chars}} = get_account(id)
    case chars |> Enum.find(fn c -> c.name == name end) do
      nil  -> {:error, :character_not_found, name}
      char -> {:ok, char}
    end
  end


  def add_char(id, char) do
    {:ok, _acc} = Entity.update_attribute(Lobby, id, Account,
      fn acc -> %Account{acc | characters: [acc.characters|char]} end)
    char
  end


  # Socket storage API

  def add_socket(id, %Socket{topic: topic} = socket) do
    Entity.update_attribute(Lobby, id, Sockets,
      fn sock -> %Sockets{sock | sockets: Map.put(sock.sockets, topic, socket)} end)
    :ok
  end

  def remove_socket(id, %Socket{topic: topic}), do: remove_socket(id, topic)
  def remove_socket(id, topic) do
    Entity.update_attribute(Lobby, id, Sockets,
      fn sock -> %Sockets{sock | sockets: Map.delete(sock.sockets, topic)} end)
    :ok
  end
end
