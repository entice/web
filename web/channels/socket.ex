defmodule Entice.Web.Socket.Helpers do
  import Phoenix.Socket

  def set_map(socket, map),             do: socket |> assign(:map, map)
  def map(socket),                      do: socket.assigns[:map]

  def set_entity_id(socket, entity_id), do: socket |> assign(:entity_id, entity_id)
  def entity_id(socket),                do: socket.assigns[:entity_id]

  def set_client_id(socket, client_id), do: socket |> assign(:client_id, client_id)
  def client_id(socket),                do: socket.assigns[:client_id]

  def set_character(socket, character), do: socket |> assign(:character, character)
  def character(socket),                do: socket.assigns[:character]

  def set_name(socket, name),           do: socket |> assign(:name, name)
  def name(socket),                     do: socket.assigns[:name]
end


defmodule Entice.Web.Socket do
  use Phoenix.Socket
  alias Entice.Logic.Maps
  alias Entice.Web.Token
  import Entice.Web.Socket.Helpers
  import Phoenix.Naming


  ## Channels
  channel "entity:*",   Entice.Web.EntityChannel
  channel "group:*",    Entice.Web.GroupChannel
  channel "movement:*", Entice.Web.MovementChannel
  channel "skill:*",    Entice.Web.SkillChannel
  channel "social:*",   Entice.Web.SocialChannel
  channel "vitals:*",   Entice.Web.VitalsChannel


  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket, timeout: 60_000
  # transport :longpoll, Phoenix.Transports.LongPoll


  def connect(%{"client_id" => client_id, "entity_token" => token, "map" => map}, socket) do
    try_connect(
      client_id, token, socket,
      Token.get_token(client_id),
      Maps.get_map(camelize(map)))
  end

  defp try_connect(
      client_id, token, socket,
      {:ok, token, :entity, %{entity_id: entity_id, map: map_mod, char: char}},
      {:ok, map_mod}) do
    socket = socket
      |> set_map(map_mod)
      |> set_entity_id(entity_id)
      |> set_client_id(client_id)
      |> set_character(char)
      |> set_name(char.name)
    {:ok, socket}
  end
  defp try_connect(_client_id, _token, _socket, _token_return, _map_return),
  do: :ignore


  def id(socket), do: id_by_entity(socket |> entity_id)
  def id_by_entity(entity_id), do: "socket:entity:#{entity_id}"
end
