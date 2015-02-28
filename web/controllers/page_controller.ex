defmodule Entice.Web.PageController do
  use Phoenix.Controller
  import Entice.Web.ControllerHelper


  plug :ensure_login when action in [:client]
  plug :action
  plug :put_view, Entice.Web.PageView


  def index(conn, _),     do: conn |> render "index.html"
  def auth(conn, _),      do: conn |> render "auth.html"

  def not_found(conn, _), do: conn |> render "not_found.html"
  def error(conn, _),     do: conn |> render "error.html"

  def client(conn, %{"map" => map}) do
    conn |> render "client.html", map: map
  end
end
