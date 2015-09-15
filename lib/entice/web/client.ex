defmodule Entice.Web.Client do
  alias Entice.Web.Account
  alias Entice.Web.Client
  alias Entice.Entity
  import Plug.Conn
  alias Entice.Web.Queries


  @doc """
  Stores client related plain data
  """
  defstruct entity_id: nil


  def exists?(id), do: Entity.exists?(id)


  def logged_in?(%Plug.Conn{} = conn),      do: exists?(get_session(conn, :client_id))
  def logged_in?(id) when is_bitstring(id), do: exists?(id)

  def logged_out?(conn), do: not logged_in?(conn)


  @doc "Internal api, for tests and so on."
  def add(%Account{} = acc), do: log_in({:ok, acc})


  def log_in(email, password), do: log_in(Queries.get_account(email, password))
  defp log_in({:error, _msg}), do: :error
  defp log_in({:ok, acc}) do
    existing = Client.Server.get_client(acc.email)

    {:ok, id, _pid} = case existing do
      id when is_bitstring(id) -> {:ok, id, :no_pid}
      nil -> Entity.start(UUID.uuid4(), %{Account => acc})
    end

    Client.Server.set_client(acc.email, id)

    {:ok, id}
  end


  def log_out(id) do
    {:ok, %Account{email: email}} = get_account(id)

    case get_entity(id) do
      eid when is_bitstring(eid) -> Entity.stop(eid)
      _ ->
    end

    Client.Server.remove_client(email)
    Entity.stop(id)
  end


  # Account api


  def get_account(id) do
    acc = Entity.fetch_attribute!(id, Account)
    {:ok, acc} = Queries.update_account(acc)
    set_account(id, acc)
    {:ok, acc}
  end


  def set_account(id, %Account{} = acc), do: Entity.put_attribute(id, acc)


  # Chars api


  def get_char(id, name) do
    {:ok, %Account{characters: chars}} = get_account(id)
    case chars |> Enum.find(fn c -> c.name == name end) do
      nil  -> {:error, :character_not_found, name}
      char -> {:ok, char}
    end
  end


  # Entity api


  def set_entity(id, entity_id),
  do: Entity.put_attribute(id, %Client{entity_id: entity_id})


  def get_entity(id) do
    case Entity.fetch_attribute(id, Client) do
      {:ok, %Client{entity_id: entity_id}} -> entity_id
      _ -> nil
    end
  end
end


defmodule Entice.Web.Client.Server do
  use GenServer

  def start_link,
  do: Agent.start_link(fn -> %{} end, name: __MODULE__)

  def set_client(email, client_id) when is_bitstring(email),
  do: Agent.update(__MODULE__, &Map.put(&1, email, client_id))

  def get_client(email) when is_bitstring(email),
  do: Agent.get(__MODULE__, &Map.get(&1, email))

  def remove_client(email) when is_bitstring(email),
  do: Agent.update(__MODULE__, &Map.delete(&1, email))
end
