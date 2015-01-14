defmodule Entice.Web.Auth do
  @moduledoc """
  This module does handle the authentication stuff.
  """
  alias Entice.Web.Clients
  import Plug.Conn
  import Phoenix.Controller

  # use as plug to filter for logged in clients:
  def ensure_login(conn, _opts), do: internal_login(conn, logged_in?(conn))
  defp internal_login(conn, true), do: conn
  defp internal_login(conn, false) do
    conn
    |> put_flash(:message, "You need to login.")
    |> redirect(to: "/")
    |> halt
  end


  def logged_in?(%Plug.Conn{} = conn), do: Clients.exists?(get_session(conn, :client_id))
  def logged_in?(id) when is_bitstring(id), do: Clients.exists?(id)

  def logged_out?(conn), do: not logged_in?(conn)
end
