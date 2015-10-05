defmodule Entice.Web.MovementChannel do
  use Entice.Web.Web, :channel
  use Entice.Logic.Attributes
  alias Entice.Entity
  alias Entice.Logic.Area
  alias Entice.Logic.Movement, as: Move
  alias Entice.Entity.Coordination
  alias Phoenix.Socket


  def join("movement:" <> map, _message, %Socket{assigns: %{map: map_mod}} = socket) do
    {:ok, ^map_mod} = Area.get_map(camelize(map))
    Process.flag(:trap_exit, true)
    send(self, :after_join)
    {:ok, socket}
  end


  def handle_info(:after_join, socket) do
    Coordination.register_observer(self)
    :ok = Move.register(socket |> entity_id)
    socket |> push("join:ok", %{})
    {:noreply, socket}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}


  # Incoming


  def handle_in("update", %{
      "pos" => %{"x" => x, "y" => y, "plane" => pos_plane} = pos,
      "goal" => %{"x" => x, "y" => y, "plane" => goal_plane} = goal,
      "movetype" => mtype,
      "velocity" => velo}, socket)
  when mtype in 0..10 and velo in -1..2 do
    Entity.put_attribute(socket |> entity_id, %Position{pos: %Coord{x: x, y: y}})
    Move.change_goal(socket |> entity_id, %Coord{x: x, y: y}, plane)
    Move.change_move_type(socket |> entity_id, mtype, velo)

    broadcast!(socket, "update", %{entity: socket |> entity_id, pos: pos, goal: goal, movetype: mtype, velocity: velo})

    {:noreply, socket}
  end


  # Leaving the socket (voluntarily or forcefully)


  def terminate(_msg, socket) do
    Move.unregister(socket |> entity_id)
    :ok
  end
end

