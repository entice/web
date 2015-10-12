defmodule Entice.Web.AuthController do
  use Entice.Web.Web, :controller

  def login(conn, %{"email" => email, "password" => password, "client_version" => client_version}) do
    if client_version == Application.get_env(:entice_web, :client_version),
    do: login(conn, email, password, Client.logged_out?(conn)),
    else: conn |> json(error(%{message: "Invalid Client Version"}))
  end

  def login(conn, params), do: conn |> json error(%{message: "Expected param 'email, password, client_version', got: #{inspect params}"})

  defp login(conn, _email, _password, false), do: conn |> json error(%{message: "Already logged in."})
  defp login(conn, email, password, true),    do: Client.log_in(email, password) |> maybe_log_in(conn, email)


  defp maybe_log_in(:error, conn, _email), do: conn |> json error(%{message: "Authentication failed."})
  defp maybe_log_in({:ok, id}, conn, email) do
    conn
    |> put_session(:email, email)
    |> put_session(:client_id, id)
    |> json ok(%{message: "Logged in."})
  end


  def logout(conn, params), do: logout(conn, params, Client.logged_in?(conn))

  defp logout(conn, _params, false), do: conn |> json error(%{message: "Already logged out."})
  defp logout(conn, _params, true) do
    Client.log_out(get_session(conn, :client_id))
    conn
    |> configure_session(renew: true)
    |> json ok(%{message: "Logged out."})
  end
end
