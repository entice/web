defmodule Entice.Web.Groups do
  alias Entice.Area.Entity

  # Attribute to be attached to a group entity
  defmodule Group, do: defstruct leader: "", members: [], invited: []

  # Attribute to be attached to a player
  defmodule Member, do: defstruct group: ""


  # Server-internal API


  @doc """
  Initializes this entity with a new group.
  """
  def create_for(map, entity_id) do
    {:ok, id} = Entity.start(map, UUID.uuid4(), %{Group => %Group{leader: entity_id}})
    Entity.put_attribute(map, entity_id, %Member{group: id})
  end

  @doc """
  Returns this entity's group id
  """
  def get_for(map, entity_id) do
    {:ok, %Member{group: group_id}} = Entity.get_attribute(map, entity_id, Member)
    {:ok, group}                    = Entity.get_attribute(map, group_id, Group)
    {:ok, group_id, group}
  end

  @doc """
  Assign a player to an existing group.
  Note that this doesnt care for exiting groups of the player.
  Use merge to merge existing groups.
  """
  def assign_to(map, entity_id, group_id) do
    assign_to(map, entity_id, group_id, Entity.get_attribute(map, group_id, Group))
  end

  defp assign_to(map, entity_id, group_id, {:ok, %Group{members: mems}}) do
    if not (entity_id in mems) do
      Entity.update_attribute(map, group_id, Group,
        fn g -> %Group{g | members: g.members ++ entity_id} end)
    end
    Entity.put_attribute(map, entity_id, %Member{group: group_id})
    :ok
  end

  defp assign_to(_map, _entity_id, _group_id, {:error, _msg}) do
    :error
  end

  @doc """
  Deletes the group of this entity.
  """
  def delete_for(map, entity_id) do
    leave_group(map, entity_id)
    {:ok, %Member{group: grp}} = Entity.get_attribute(map, entity_id, Member)
    Entity.stop(map, grp)
    Entity.remove_attribute(map, entity_id, Member)
  end

  @doc """
  Checks if this player is a leader of a group,
  if so, return the members.
  """
  def get_my_members(map, entity_id) do
    {:ok, %Member{group: grp}} = Entity.get_attribute(map, entity_id, Member)
    {:ok, %Group{leader: id, members: mems}} = Entity.get_attribute(map, grp, Group)

    case id == entity_id do
      true  -> mems
      false -> []
    end
  end

  @doc """
  Prepare a new group in the new map. Create all the entity-ids and return
  a map from the old entity-ids to the new ones. The resulting map also contains the new groups id,
  which is also mapped to its old one.
  """
  def prepare_area_change(map, new_map, group_id) do
    prepare_area_change(map, new_map, group_id, Entity.get_attribute(map, group_id, Group))
  end

  defp prepare_area_change(_map, new_map, group_id, {:ok, %Group{leader: lead, members: mems}}) do
    # create new ids
    leader = UUID.uuid4()
    members = mems |> Enum.map(&({&1, UUID.uuid4()}))

    # create a new group out of them
    {:ok, new_grp} = Entity.start(new_map, UUID.uuid4(), %{Group => %Group{
      leader: leader,
      members: members |> Enum.map(&(elem(&1, 1))) }})

    # create the mapping
    Enum.reduce(members, %{}, fn {old, new}, acc -> Map.put(acc, old, new) end)
    |> Map.put(group_id, new_grp)
    |> Map.put(lead, leader)
  end


  @doc """
  Leave a group, become the leader of a new one.
  """
  def leave_group(map, entity_id) do
    {:ok, %Member{group: grp}} = Entity.get_attribute(map, entity_id, Member)
    leave_group_internal(map, entity_id, grp, Entity.get_attribute(map, grp, Group))
  end

  defp leave_group_internal(_,   id, _,     {:ok, %Group{leader: id, members: []}}), do: :ok

  defp leave_group_internal(map, id, group, {:ok, %Group{leader: id, members: [hd | tl]}}) do
    Entity.update_attribute(map, group, Group, fn g -> %Group{g | leader: hd, members: tl} end)
    create_for(map, id)
    :ok
  end

  defp leave_group_internal(map, id, group, {:ok, _grp}) do
    Entity.update_attribute(map, group, Group, fn g -> %Group{g | members: g.members -- [id]} end)
    create_for(map, id)
    :ok
  end


  # Client API


  @doc """
  Tries to invite or merge the group of another player
  """
  def merge(map, entity_id, target_id) do
    {:ok, %Member{group: grp1}} = Entity.get_attribute(map, entity_id, Member)
    {:ok, %Member{group: grp2}} = Entity.get_attribute(map, target_id, Member)
    merge_internal1(
      map,
      entity_id,
      grp1, Entity.get_attribute(map, grp1, Group),
      grp2, Entity.get_attribute(map, grp2, Group))
  end

  # accept an invite
  defp merge_internal1(map, id1, grp1, {:ok, %Group{leader: id1} = group1}, grp2, {:ok, %Group{invited: inv}}) when grp1 != grp2 do
    if grp1 in inv do
      # if already invited, merge
      Entity.update_attribute(map, grp2, Group,
        fn g -> %Group{g |
          members: g.members ++ [group1.leader] ++ group1.members,
          invited: g.invited -- [grp1]}
        end)
      Entity.stop(map, grp1)
      Entity.put_attribute(map, id1, %Member{group: grp2})
    else
      # if not, invite!
      Entity.update_attribute(map, grp1, Group, fn g -> %Group{g | invited: [grp2, g.invited]} end)
    end
    :ok
  end

  # fallback -> error
  defp merge_internal1(_map, _id1, _grp1, _g1, _grp2, _g2), do: :error


  @doc """
  Tries to throw a player out of the group, or declines an invite, or leaves the group.
  """
  def kick(map, entity_id, entity_id), do: leave_group(map, entity_id)
  def kick(map, entity_id, target_id) do
    {:ok, %Member{group: grp1}} = Entity.get_attribute(map, entity_id, Member)
    {:ok, %Member{group: grp2}} = Entity.get_attribute(map, target_id, Member)
    kick_internal1(
      map,
      entity_id,
      grp1, Entity.get_attribute(map, grp1, Group),
      target_id,
      grp2, Entity.get_attribute(map, grp2, Group))
  end

  # as leader, throw out a player
  defp kick_internal1(map, id1, grp1, {:ok, %Group{leader: id1}}, id2, grp1, {:ok, _group2}) do
    leave_group(map, id2)
    :ok
  end

  # decline an invite
  defp kick_internal1(map, id1, grp1, {:ok, %Group{leader: id1, invited: inv1}}, _id2, grp2, {:ok, %Group{invited: inv2}}) when grp1 != grp2 do
    cond do
      grp1 in inv2 -> Entity.update_attribute(map, grp2, Group, fn g -> %Group{g | invited: g.invited -- [grp1]} end)
      grp2 in inv1 -> Entity.update_attribute(map, grp1, Group, fn g -> %Group{g | invited: g.invited -- [grp2]} end)
      true -> :ok # this can fail due to clien racing conditions
    end
    :ok
  end

  # fallback -> error
  defp kick_internal1(_map, _id1, _grp1, _g1, _id2, _grp2, _g2), do: :error
end
