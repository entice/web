defmodule Entice.Web.Client do
  alias Entice.Web.Account
  alias Entice.Web.Client
  alias Entice.Web.Queries
  alias Entice.Entity
  alias Entice.Logic.Player
  import Plug.Conn

  @doc """
  Stores client related plain data
  """
  defstruct entity_id: nil, online_status: :offline


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
    Client.Server.set_client(acc.id, id)

    {:ok, id}
  end


  def log_out(id) do
    {:ok, %Account{email: email, id: account_id}} = get_account(id)

    case get_entity(id) do
      eid when is_bitstring(eid) -> Entity.stop(eid)
      _ ->
    end

    Client.Server.remove_client(email)
    Client.Server.remove_client(account_id)

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

  # Friends api

  def get_friends(id) do
    {:ok, %Account{friends: friends}} = get_account(id)
    {:ok, friends}
  end

  @doc "Returns the first character of an account."
  def get_first_char(account_id) do
    case Entice.Web.Repo.get(Entice.Web.Account, account_id) do
      nil -> {:error, :no_matching_account}
      acc ->
        acc = Entice.Web.Repo.preload(acc, :characters)
        case acc.characters do
          chars when hd(chars) -> {:error, "No Character"}
          chars -> {:ok, hd(chars).name}
        end
    end
  end

  @doc "Returns a friend's online status and character name from his account id."
  def get_status(account_id) do
    {account_id, _} = Integer.parse(account_id)

    case Client.Server.get_client(account_id) do
      nil ->
        case get_first_char(account_id) do
          {result, name} when is_bitstring(name) -> {:ok, :offline, name}
          _ -> {:error, :no_matching_account}
        end
      id ->
        attribute = Entity.fetch_attribute(id, Client)
        if attribute == :error do
          case get_first_char(account_id) do
            {result, name} when is_bitstring(name) ->{:ok, :offline, name}
            _ -> {:error, :no_matching_account}
          end
        else
          {:ok, client} = attribute
          player = Player.attributes(client.entity_id)
          {:ok, client.online_status, player[Player.Name].name}
        end
    end
  end

  # Entity api


  def set_entity(id, entity_id),
  do: Entity.put_attribute(id, %Client{entity_id: entity_id, online_status: :online})


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

  def set_client(key, client_id) do
    case key do
      account_id when is_integer(account_id) -> Agent.update(__MODULE__, &Map.put(&1, account_id, client_id))
      email when is_bitstring(email) -> Agent.update(__MODULE__, &Map.put(&1, email, client_id))
    end
  end

  def get_client(key) do
    case key do
      account_id when is_integer(account_id) -> Agent.get(__MODULE__, &Map.get(&1, account_id))
      email when is_bitstring(email) -> Agent.get(__MODULE__, &Map.get(&1, email))
    end
  end

  def remove_client(key) do
    case key do
      account_id when is_integer(account_id) -> Agent.update(__MODULE__, &Map.delete(&1, account_id))
      email when is_bitstring(email) -> Agent.update(__MODULE__, &Map.delete(&1, email))
    end
  end
end
