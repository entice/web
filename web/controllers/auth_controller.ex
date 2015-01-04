defmodule Entice.Web.AuthController do
  use Phoenix.Controller
  alias Entice.Web.Auth
  import Entice.Web.ApiMessage

  plug :action


  def login(conn, params), do: login(conn, params, Auth.logged_out?(conn))

  def login(conn, _params, true) do
    email = conn.params["email"]
    password = conn.params["password"]
    id = UUID.uuid4()

    Auth.is_valid?(email, password)
    |> maybe_log_in(conn, email, id)
  end

  def login(conn, _params, false) do
    conn |> json error(%{message: "Already logged in."})
  end

  def maybe_log_in(true, conn, email, id) do
    conn
    |> put_session(:email, email)
    |> put_session(:auth_token, id)
    |> put_session(:logged_in, true)
    |> json ok(%{
      message: "Logged in.",
      auth_token: id})
  end

  def maybe_log_in(false, conn, _email, _id) do
    conn |> json error(%{message: "Authentication failed."})
  end


  def logout(conn, params), do: logout(conn, params, Auth.logged_in?(conn))

  def logout(conn, _params, true) do
    conn
    |> configure_session(renew: true)
    |> put_session(:logged_in, false)
    |> json ok(%{message: "Logged out."})
  end

  def logout(conn, _params, false) do
    conn |> json error(%{message: "Already logged out."})
  end
end
