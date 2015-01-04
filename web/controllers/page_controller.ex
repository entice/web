defmodule Entice.Web.PageController do
  use Phoenix.Controller

  plug :action
  plug :put_view, Entice.Web.PageView


  def index(conn, _),     do: conn |> render "index.html"
  def auth(conn, _),      do: conn |> render "auth.html"
  def chat(conn, _),      do: conn |> render "chat.html"

  def not_found(conn, _), do: conn |> render "not_found.html"
  def error(conn, _),     do: conn |> render "error.html"


  def client(conn, %{"area" => area}) do
    conn |> render "client.html", area: area
  end
end
