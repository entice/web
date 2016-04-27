defmodule Entice.Web.Client do
  alias Entice.Web.{Account, Client, Queries}
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
      _ -> nil
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
  #TODO: clean up and use idiomatic pipes or what to make this more concise
  @doc "Returns a friend's online status and character name from their account id."
  def get_status(friend_name) do
    case Queries.get_account_id(friend_name) do
      {:ok, account_id} ->
        case Client.Server.get_client_by_account_id(account_id) do
          nil -> {:ok, :offline, friend_name}
          client_id ->
            case Entity.fetch_attribute(client_id, Client) do
              :error -> {:ok, :offline, friend_name}
              {:ok, client} ->
                case Player.attributes(client.entity_id) do
                  :error -> {:ok, :offline, friend_name}
                  player -> {:ok, client.online_status, player[Player.Name].name}
                end
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
