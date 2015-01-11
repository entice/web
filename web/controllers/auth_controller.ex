defmodule Entice.Web.AuthController do
  use Phoenix.Controller
  import Entice.Web.Auth
  import Entice.Web.ApiMessage


  plug :action


  def login(conn, params), do: login(conn, params, logged_out?(conn))

  defp login(conn, _params, false), do: conn |> json error(%{message: "Already logged in."})
  defp login(conn, _params, true) do
    email = conn.params["email"]
    password = conn.params["password"]

    try_log_in(email, password)
    |> maybe_log_in(conn, email)
  end


  defp maybe_log_in(:error, conn, _email), do: conn |> json error(%{message: "Authentication failed."})
  defp maybe_log_in({:ok, id}, conn, email) do
    conn
    |> put_session(:email, email)
    |> put_session(:client_id, id)
    |> json ok(%{message: "Logged in."})
  end


  def logout(conn, params), do: logout(conn, params, logged_in?(conn))

  defp logout(conn, _params, false), do: conn |> json error(%{message: "Already logged out."})
  defp logout(conn, _params, true) do
    conn
    |> configure_session(renew: true)
    |> json ok(%{message: "Logged out."})
  end
end
