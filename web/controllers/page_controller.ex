defmodule Entice.Web.PageController do
  use Entice.Web.Web, :controller

  plug :ensure_login when action in [:client]
  plug :put_view, Entice.Web.PageView


  def index(conn, _),     do: conn |> render "index.html"
  def auth(conn, _),      do: conn |> render "auth.html"
  def account(conn, _),   do: conn |> render "account.html"

  def not_found(conn, _), do: conn |> render "not_found.html"
  def error(conn, _),     do: conn |> render "error.html"

  def client(conn, %{"map" => map}) do
    conn |> render "client.html", map: map
  end
end
