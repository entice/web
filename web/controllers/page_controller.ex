defmodule Entice.Web.PageController do
  use Entice.Web.Web, :controller

  plug :ensure_login when action in [:client, :invitation]
  plug :put_view, Entice.Web.PageView


  def index(conn, _),      do: conn |> render "index.html"
  def invitation(conn, _), do: conn |> render "invitation.html"
  def friend(conn, _),     do: conn |> render "friend.html"
  def not_found(conn, _),  do: conn |> render "not_found.html"
  def error(conn, _),      do: conn |> render "error.html"


  def auth(conn, _) do
    client_version = Application.get_env(:entice_web, :client_version)
    conn |> render "auth.html", client_version: client_version
  end

  def account(conn, _) do
    client_version = Application.get_env(:entice_web, :client_version)
    conn |> render "account.html", client_version: client_version
  end

  def client(conn, %{"map" => map}),
  do: conn |> render "client.html", map: map

  def client(conn, _params),
  do: conn |> send_resp 400, "The client needs a 'map' parameter to work"
end
