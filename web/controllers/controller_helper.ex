defmodule Entice.Web.ControllerHelper do
  @moduledoc """
  Simple API message helpers, that are kinda like templates but more simple.
  """
  alias Entice.Web.Client
  import Plug.Conn
  import Phoenix.Controller


  # use as plug to filter for logged in clients:
  def ensure_login(conn, _opts) do
    case Client.logged_in?(get_session(conn, :client_id)) do
      true  -> conn
      false -> conn
        |> put_flash(:message, "You need to login.")
        |> redirect(to: "/")
        |> halt
    end
  end


  def ok(msg), do: Map.merge(%{status: :ok}, msg)
  def error(msg), do: Map.merge(%{status: :error}, msg)
end
