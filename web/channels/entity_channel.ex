defmodule Entice.Web.EntityChannel do
  use Phoenix.Channel
  use Entice.Logic.Area
  use Entice.Logic.Attributes
  alias Entice.Web.Client
  alias Entice.Web.Player
  alias Entice.Web.Spawning
  import Phoenix.Naming
  import Entice.Web.ChannelHelper


  # Initializing the connection


  def join("entity:" <> map, %{"client_id" => client_id, "player_token" => token}, socket) do
    {:ok, ^token, :player, %{area: map_mod, char: char}} = Client.get_token(client_id)
    {:ok, ^map_mod} = Area.get_map(camelize(map))
    Client.delete_token(client_id)

    # link the client and the entity to the new socket
    {:ok, entity_id} = Player.init(map_mod, char)
    Spawning.init(entity_id, map_mod)

    socket = socket
      |> set_area(map_mod)
      |> set_entity_id(entity_id)
      |> set_client_id(client_id)
      |> set_character(char)

    # create access token for other channels
    {:ok, token} = Client.create_token(socket |> client_id, :player, %{
      area: map_mod,
      entity_id: entity_id,
      char: socket |> character})

    socket |> reply("join:ok", %{access_token: token, entity: entity_id})
    {:ok, socket}
  end


  # Outgoing Event API


  def handle_out("report_existing",  %{new: new_entity_id, existing: entity_id, attributes: attributes}, socket) do
    if (new_entity_id == socket |> entity_id),
    do: socket |> reply("entity:add", %{entity_id: entity_id, attributes: attributes})
    {:ok, socket}
  end


  def handle_out(_event, _message, socket), do: {:ok, socket}


  # Socket leave


  def leave(_msg, socket) do
    Spawning.remove(socket |> entity_id)
    Player.stop(socket |> area, socket |> entity_id)
    {:ok, socket}
  end
end
