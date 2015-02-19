defmodule Entice.Web.Client do
  alias Entice.Web.Account
  alias Entice.Entity
  import Plug.Conn
  import Entice.Web.Queries


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

    {:ok, id, _pid} = case existing do
      %{id: id} -> {:ok, id, :no_pid}
      nil -> Entity.start(UUID.uuid4(), %{Account => acc})
    end

    {:ok, id}
  end


  def log_out(id), do: Entity.stop(id)


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
