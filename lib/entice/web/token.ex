defmodule Entice.Web.Token do
  alias Entice.Web.Client
  alias Entice.Entity
  alias Entice.Web.Token
  @moduledoc """
  This adds an access token to a client entity.
  Access tokens can carry various kinds of data.
  This accesses the entity directly and is not a behaviour.
  """


  # This attribute is only useable with a client.
  defstruct id: "", type: :simple, payload: %{}


  def create_token(id, type \\ :simple, payload \\ %{}) do
    tid = UUID.uuid4()
    Entity.put_attribute(id, %Token{id: tid, type: type, payload: payload})
    {:ok, tid}
  end


  def create_entity_token(id, %{entity_id: _} = payload),
  do: create_token(id, :entity, payload)


  def create_mapchange_token(id, %{entity_id: _} = payload),
  do: create_token(id, :mapchange, payload)


  def get_token(id) when is_bitstring(id), do: get_token(Entity.fetch_attribute(id, Token))
  def get_token({:ok, token}),             do: {:ok, token.id, token.type, token.payload}
  def get_token({:error, _reason}),        do: {:error, :token_not_found}


  def delete_token(id), do: Entity.remove_attribute(id, Token)
end
