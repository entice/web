defmodule EnticeServer.PageController do
  use Phoenix.Controller
  alias Phoenix.Controller.Flash

  plug :action

  def index(conn, _),     do: conn |> render "index.html"
  def chat(conn, _),      do: conn |> render "chat.html"
  def not_found(conn, _), do: conn |> render "not_found.html"
  def error(conn, _),     do: conn |> render "error.html"

  def auth(conn, _params) do
    id = UUID.uuid1
    conn
    |> put_session(:auth_token, id)
    |> Flash.put(:message, "... authorized #{id} ...")
    |> redirect("/")
  end

  def test(conn, _params) do
    id = get_session(conn, :auth_token)
    conn
    |> Flash.put(:message, "... test authorized: #{id} ...")
    |> redirect("/")
  end
end
