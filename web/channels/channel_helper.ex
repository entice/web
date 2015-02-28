defmodule Entice.Web.ChannelHelper do
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
