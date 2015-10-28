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
    existing = Client.Server.get_client_by_email(acc.email)

    {:ok, id, _pid} = case existing do
      id when is_bitstring(id) -> {:ok, id, :no_pid}
      nil -> Entity.start(UUID.uuid4(), %{Account => acc})
    end

    Client.Server.set_client_by_email(acc.email, id)
    Client.Server.set_client_by_account_id(acc.id, id)

    {:ok, id}
  end


  def log_out(id) do
    {:ok, %Account{email: email, id: account_id}} = get_account(id)

    case get_entity(id) do
      eid when is_bitstring(eid) -> Entity.stop(eid)
      _ ->
    end

    Client.Server.remove_client_by_email(email)
    Client.Server.remove_client_by_account_id(account_id)

    Entity.stop(id)
  end


  # Account api


  @doc "Will always update the account data we have stored, in case the data in the db changed"
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

  #TODO: Add current map to status when map is server side
  @doc "Returns a friend's online status and character name from their account id."
  def get_status(friend_name) do
    case Queries.get_account_id(friend_name) do
      {:ok, account_id} ->
        case Client.Server.get_client_by_account_id(account_id) do
          nil -> {:ok, :offline, friend_name}
          id ->
            case Entity.fetch_attribute(id, Client) do
              :error -> {:ok, :offline, friend_name}
              {:ok, client} ->
                player = Player.attributes(client.entity_id)
                {:ok, client.online_status, player[Player.Name].name}
            end
        end
      #If char with that name has been deleted (If name is then taken by another account it will be a problem)
      _ -> {:ok, :offline, friend_name}
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


#TODO: maybe this needs to be replaced by a proper ETS implementation or so
# especially since we don't monitor registered clients
defmodule Entice.Web.Client.Server do
  use GenServer


  def start_link,
  do: Agent.start_link(fn -> %{} end, name: __MODULE__)


  def set_client_by_account_id(account_id, client), do: set_client(:account_id, account_id, client)
  def set_client_by_email(email, client),           do: set_client(:email, email, client)

  defp set_client(map_key, key, client_id) when is_atom(map_key) do
    Agent.update(__MODULE__,
      fn state ->
        new_entry = Map.put(%{}, key, client_id)
        Map.update(state, map_key, new_entry, fn map -> Map.merge(map, new_entry) end)
      end)
  end


  def get_client_by_account_id(account_id), do: get_client(:account_id, account_id)
  def get_client_by_email(email),           do: get_client(:email, email)

  def get_client(map_key, key) when is_atom(map_key) do
    Agent.get_and_update(__MODULE__,
      fn state ->
        state
        |> Map.get(map_key)
        |> case do
             %{} = map -> {Map.get(map, key), state}
             nil       -> {nil, Map.put(state, map_key, %{})}
           end
      end)
  end


  def remove_client_by_account_id(account_id), do: remove_client(:account_id, account_id)
  def remove_client_by_email(email),           do: remove_client(:email, email)

  def remove_client(map_key, key) when is_atom(map_key) do
    Agent.update(__MODULE__,
      fn state ->
        state
        |> Map.get(map_key)
        |> case do
             %{} = map -> Map.put(state, map_key, Map.delete(map, key))
             nil       -> state
           end
      end)
  end
end
