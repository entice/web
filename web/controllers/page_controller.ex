defmodule Entice.Web.PageController do
  import Plug.Conn
  import Phoenix.Controller

  use Phoenix.Controller.Pipeline

  plug Phoenix.Controller.Logger
  plug :put_view, Entice.Web.PageView
  plug :action


  def index(conn, _),     do: conn |> render "index.html"
  def chat(conn, _),      do: conn |> render "chat.html"
  def not_found(conn, _), do: conn |> render "not_found.html"
  def error(conn, _),     do: conn |> render "error.html"


  def auth(conn, _params) do
    id = UUID.uuid1
    conn
    |> put_session(:auth_token, id)
    |> put_flash(:message, "... authorized #{id} ...")
    |> redirect(to: "/")
  end

  def test(conn, _params) do
    id = get_session(conn, :auth_token)
    conn
    |> put_flash(:message, "... test authorized: #{id} ...")
    |> redirect(to: "/")
  end
end
