defmodule Entice.Web.PageController do
  use Phoenix.Controller

  plug :action
  plug :put_view, Entice.Web.PageView


  def index(conn, _),     do: conn |> render "index.html"
  def chat(conn, _),      do: conn |> render "chat.html"
  def auth(conn, _),      do: conn |> render "auth.html"

  def not_found(conn, _), do: conn |> render "not_found.html"
  def error(conn, _),     do: conn |> render "error.html"



  def test(conn, _params) do
    id = get_session(conn, :auth_token)
    conn
    |> put_flash(:message, "... test authorized: #{id} ...")
    |> redirect(to: "/")
  end
end
