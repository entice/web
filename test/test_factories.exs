defmodule Entice.Test.Factories do
  @moduledoc """
  Stuff à la factory_girl, but with a bit more concrete flavour.
  """
  use Entice.Logic.Attributes
  use Phoenix.ChannelTest
  alias Entice.Entity
  alias Entice.Logic.Player
  alias Entice.Web.Account
  alias Entice.Web.Character
  alias Entice.Web.Client
  alias Entice.Web.Token
  alias Entice.Test.Factories.Counter
  import Entice.Utils.StructOps


  @endpoint Entice.Web.Endpoint


  def create_character(name \\ "Some Char #{Counter.get_num(:character_name)}"),
  do: %Character{name: name}


  def create_account,                      do: create_account([create_character])
  def create_account(%Character{} = char), do: create_account([char])
  def create_account(characters),
  do: %Account{
    email: "somemail#{Counter.get_num(:account_email)}@example.com",
    characters: characters,
    id: Counter.get_num(:account_id)} #Maybe add incremented id here?


  def create_client do
    {:ok, id} = Client.add(create_account)
    id
  end


  def create_client(%Account{} = acc) do
    {:ok, id} = Client.add(acc)
    id
  end


  def create_entity do
    {:ok, id, pid} = Entity.start
    {id, pid}
  end


  def create_entity(id) do
    {:ok, id, pid} = Entity.start(id)
    {id, pid}
  end

  def create_player(topic, map) when is_bitstring(topic) and is_atom(map) do
    char       = create_character
    acc        = create_account(char)
    cid        = create_client(acc)
    {eid, pid} = create_entity
    {:ok, tid} = Token.create_entity_token(cid, %{entity_id: eid, map: map, char: char})

    Player.register(eid, map, char.name, copy_into(%Appearance{}, char))

    {:ok, socket} = connect(Entice.Web.Socket, %{"client_id" => cid, "entity_token" => tid, "map" => map.underscore_name})

    %{character: char, account: acc, client_id: cid, entity_id: eid, entity: pid, token: tid, socket: socket}
  end
end


defmodule Entice.Test.Factories.Counter do
  use GenServer

  def start_link,
  do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def get_num(key) when is_atom(key),
  do: GenServer.call(__MODULE__, {:num, key})

  # internal...

  def handle_call({:num, key}, _sender, state) do
    new_state = Map.update(state, key, 1, fn count -> count + 1 end)
    {:reply, Map.get(new_state, key), new_state}
  end
end
