defmodule Entice.Test.Factories do
  @moduledoc """
  Stuff à la factory_girl, but with a bit more concrete flavour.
  """
  use Entice.Logic.Attributes
  alias Entice.Entity
  alias Entice.Logic.Player
  alias Entice.Web.Account
  alias Entice.Web.Character
  alias Entice.Web.Client
  alias Entice.Web.Token
  alias Entice.Test.Factories.Counter
  alias Phoenix.Socket
  import Entice.Utils.StructOps


  def create_character(name \\ "Some Char #{Counter.get_num(:character_name)}"),
  do: %Character{name: name}


  def create_account,                      do: create_account([create_character])
  def create_account(%Character{} = char), do: create_account([char])
  def create_account(characters),
  do: %Account{
    email: "somemail#{Counter.get_num(:account_email)}@example.com",
    characters: characters}


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


  def create_socket(topic, pid \\ self) do
    %Socket{
      transport_pid: pid,
      router: Entice.Web.Router,
      topic: topic,
      assigns: [],
      pubsub_server: Entice.Web.PubSub}
  end


  def create_player(topic, map, entity_as_socket_pid \\ false) when is_bitstring(topic) and is_atom(map) do
    char       = create_character
    acc        = create_account(char)
    cid        = create_client(acc)
    {eid, pid} = create_entity
    {:ok, tid} = Token.create_entity_token(cid, %{entity_id: eid, map: map, char: char})

    socket =
      if entity_as_socket_pid do
        create_socket(topic <> ":" <> map.underscore_name, pid)
      else
        create_socket(topic <> ":" <> map.underscore_name)
      end

    Player.register(eid, map, char.name, copy_into(%Appearance{}, char))

    %{character: char, account: acc, client_id: cid, entity_id: eid, entity: pid, token: tid, socket: socket}
  end


  def create_transport do
    {:ok, pid} = Entice.Test.Factories.Transport.start_link
    pid
  end
end


defmodule Entice.Test.Factories.Transport do
  use GenServer
  alias Phoenix.Socket.Message
  alias Phoenix.Channel.Transport
  alias Phoenix.Transports.WebSocket

  def start_link,
  do: GenServer.start_link(__MODULE__, HashDict.new)

  def dispatch_join(transport, socket, payload),
  do: GenServer.call(transport, {:dispatch_join, socket, payload})

  def dispatch_message(transport, socket, event, payload),
  do: GenServer.call(transport, {:dispatch_msg, socket, event, payload})

  # internal...

  def handle_call({:dispatch_join, socket, payload}, _sender, state) do
    message = %Message{
      topic: socket.topic,
      event: "phx_join",
      ref: "1",
      payload: payload}
    {:ok, socket_pid} = 
      Transport.dispatch(
        message, state, socket.transport_pid, Entice.Web.Router, Entice.Web.Endpoint, WebSocket)
    {:reply, :ok, state |> Map.put(socket.topic, socket_pid)}
  end

  def handle_call({:dispatch_msg, socket, event, payload}, _sender, state) do
    message = %Message{
      topic: socket.topic,
      event: event,
      payload: payload}
    res = 
      Transport.dispatch(
        message, state, socket.transport_pid, Entice.Web.Router, Entice.Web.Endpoint, WebSocket)
    {:reply, res, state}
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
