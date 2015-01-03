defmodule Entice.Web.ApiController do
  use Phoenix.Controller

  plug :action


  def api_auth(conn, params) do
    email = conn.params["email"]
    password = conn.params["password"]
    id = UUID.uuid1
    conn
    |> put_session(:auth_token, id)
    |> json(%{
      message: "Zis is a fery ztupid api tezt.",
      auth_token: id,
      email: email})
  end
end
