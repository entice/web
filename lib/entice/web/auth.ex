defmodule Entice.Web.Auth do
  @moduledoc """
  This module does handle the authentication stuff.
  """
  import Plug.Conn

  # Lol
  @accs [
    {"root@entice.ps", "root"},
    {"test@entice.ps", "test"}
  ]


  def is_valid?(email, password), do: {email, password} in @accs


  def logged_in?(conn), do: get_session(conn, :logged_in)

  def logged_out?(conn) do
    if logged_in = get_session(conn, :logged_in) do
      !logged_in
    else
      true
    end
  end
end
