defmodule Entice.Web.PageController do
  use Phoenix.Controller
  import Entice.Web.Auth


  plug :ensure_login when action in [:chat, :client]
  plug :action
  plug :put_view, Entice.Web.PageView


  def index(conn, _),     do: conn |> render "index.html"
  def auth(conn, _),      do: conn |> render "auth.html"

  def not_found(conn, _), do: conn |> render "not_found.html"
  def error(conn, _),     do: conn |> render "error.html"

  def client(conn, %{"area" => area}) do
    conn |> render "client.html", map: area
  end
end
