defmodule Entice.Web.TokenController do
  use Entice.Web.Web, :controller
  alias Entice.Entity
  alias Entice.Entity.Coordination
  alias Entice.Logic.{Maps, Player, MapInstance, MapRegistry}
  alias Entice.Logic.Player.{Appearance, Position}
  alias Entice.Web.{Character, Token}
  import Entice.Utils.StructOps
  import Phoenix.Naming

  plug :ensure_login

  def entity_token(conn, %{"map" => map, "char_name" => char_name}), do: entity_token_internal(conn, map, char_name)

  def entity_token(conn, params), do: conn |> json(error(%{message: "Expected param 'map, char_name', got: #{inspect params}"}))

  defp spawn_dhuum(instance_id, map_mod) do
    MapInstance.add_npc(instance_id, "Dhuum", :dhuum, %Position{pos: map_mod.spawn})
  end

  defp start_or_get_instance(map_mod) do
    case MapRegistry.start_instance(map_mod) do
      {:ok, instance_id} ->
        #TODO: Replace following line with populating function, new file for dealing with instances, map model etc...
        spawn_dhuum(instance_id, map_mod)
        {:ok, instance_id}
      {:error, :instance_already_running} ->
        instance_id = MapRegistry.get_instance(map_mod)
        {:ok, instance_id}
    end
  end

  defp entity_token_internal(conn, map, char_name) do
    id = get_session(conn, :client_id)

    # make sure any old entities are killed before being able to play
    case Client.get_entity(id) do
      old when is_bitstring(old) -> Entity.stop(old)
      _ -> nil
    end

    {:ok, map_mod}   = Maps.get_map(camelize(map))
    {:ok, char}      = Client.get_char(id, char_name)
    {:ok, eid, _pid} = Entity.start()
    name = char.name

    # check if the player already has a mapchange token set
    :ok = case Token.get_token(id) do
      {:ok, _token, :mapchange, %{entity_id: _old_entity_id, map: ^map_mod, char: %Character{name: ^name}}} -> :ok
      {:ok, _token, :entity, _data} -> :ok
      {:error, :token_not_found} -> :ok
      token ->
        raise "Token did not match expectations. Map: #{inspect map_mod}, Char: #{inspect char}, Actual: #{inspect token}"
    end

    # create the token (or use the mapchange token)
    {:ok, token} = Token.create_entity_token(id, %{entity_id: eid, map: map_mod, char: char})

    # init the entity and update the client
    Client.set_entity(id, eid)
    Coordination.register(eid, map_mod)
    {:ok, instance_id} = start_or_get_instance(map_mod)
    MapInstance.add_player(instance_id, eid)
    Player.register(eid, map_mod, char.name, copy_into(%Appearance{}, char))

    conn |> json(ok(%{
      message: "Transferring...",
      client_id: id,
      entity_id: eid,
      entity_token: token,
      map: map_mod.underscore_name,
      is_outpost: map_mod.is_outpost?}))
  end
end
