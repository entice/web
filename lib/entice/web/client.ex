defmodule Entice.Web.Client do
  alias Entice.Web.Account
  alias Entice.Entity
  alias Phoenix.Socket
  import Plug.Conn
  import Entice.Web.Queries


  # Some additional client only attributes:
  defmodule Token, do: defstruct id: "", type: :simple, payload: %{}

  defmodule Sockets, do: defstruct sockets: %{}


  def exists?(id), do: Entity.exists?(id)


  def logged_in?(%Plug.Conn{} = conn),      do: exists?(get_session(conn, :client_id))
  def logged_in?(id) when is_bitstring(id), do: exists?(id)

  def logged_out?(conn), do: not logged_in?(conn)


  @doc "Internal api, for tests and so on."
  def add(%Account{} = acc), do: log_in({:ok, acc})


  def log_in(email, password), do: log_in(get_account(email, password))
  defp log_in({:error, _msg}), do: :error
  defp log_in({:ok, acc}) do
    existing = nil

    case existing do
      %{id: id} -> {:ok, id}
      nil -> Entity.start(UUID.uuid4(), %{Account => acc})
    end
  end


  def log_out(id), do: Entity.stop(id)


  # Transfer token api


  def create_token(id, type \\ :simple, payload \\ %{}) do
    tid = UUID.uuid4()
    Entity.put_attribute(id, %Token{id: tid, type: type, payload: payload})
    {:ok, tid}
  end


  def get_token(id) when is_bitstring(id), do: get_token(Entity.fetch_attribute(id, Token))
  def get_token({:ok, token}),      do: {:ok, token.id, token.type, token.payload}
  def get_token({:error, _reason}), do: {:error, :token_not_found}


  def delete_token(id), do: Entity.remove_attribute(id, Token)


  # Account api


  def get_account(id), do: Entity.fetch_attribute(id, Account)


  def set_account(id, %Account{} = acc), do: Entity.put_attribute(id, acc)


  # Chars api


  def get_char(id, name) do
    {:ok, %Account{characters: chars}} = get_account(id)
    case chars |> Enum.find(fn c -> c.name == name end) do
      nil  -> {:error, :character_not_found, name}
      char -> {:ok, char}
    end
  end
end
