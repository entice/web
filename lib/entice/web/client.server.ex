defmodule Entice.Web.Client.Server do
  use GenServer
  require Logger

@tables [:emails, :client_ids, :account_ids]

  def start_link, do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def get_client_by_account_id(account_id),         do: GenServer.call(__MODULE__, {:get, :account_id, account_id})
  def get_client_by_email(email),                   do: GenServer.call(__MODULE__, {:get, :email, email})

  def set_client_by_account_id(account_id, client), do: GenServer.cast(__MODULE__, {:set, :account_id, account_id, client})
  def set_client_by_email(email, client),           do: GenServer.cast(__MODULE__, {:set, :email, email, client})

  def remove_client_by_account_id(account_id),      do: GenServer.cast(__MODULE__, {:remove, :account_id, account_id})
  def remove_client_by_email(email),                do: GenServer.cast(__MODULE__, {:remove, :email, email})


  # GenServer API
  def init(:ok) do
    Enum.each(@tables, &init_table(&1))
    {:ok, :ok}
  end

  def handle_call({:get, :account_id, account_id}, _from, state) do
    id = get_client(:account_ids, account_id)
    {:reply, id, state}
  end
  def handle_call({:get, :email, email}, _from, state) do
   id = get_client(:emails, email)
   {:reply, id, state}
  end

  def handle_cast({:set, :account_id, account_id, client}, state) do 
    set_client(:account_ids, account_id, client)
    {:noreply, state}
  end
  def handle_cast({:set, :email, email, client}, state) do
    set_client(:emails, email, client)
    {:noreply, state}
  end

  def handle_cast({:remove, :account_id, account_id}, state) do
    remove_client(:account_ids, account_id)
    {:noreply, state}
  end
  def handle_cast({:remove, :email, email}, state) do
    remove_client(:emails, email)
    {:noreply, state}
  end


  # Backend API
  @spec set_client(:atom, String.t, String.t) :: true
  defp set_client(table, key, client_id) do
    :ets.insert(table, {key, client_id})
  end

  @spec get_client(:atom, String.t) :: String.t | nil
  def get_client(table, key) do
    case :ets.lookup(table, key) do
      [{_key, id}] -> id
      []           -> nil
    end
  end

  @spec remove_client(:atom, String.t) :: true
  def remove_client(table, key) do
    :ets.delete(table, key)
  end

  @spec init_table(:atom) :: true
  defp init_table(table) do
    Logger.info("Creating #{Atom.to_string(table)} database")
    :ets.new(table, [:ordered_set, :public, :named_table])
  end
end
