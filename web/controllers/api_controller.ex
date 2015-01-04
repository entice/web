defmodule Entice.Web.ApiController do
  use Phoenix.Controller

  plug :action


  # Lol
  @accs [
    {"root@entice.ps", "root"},
    {"test@entice.ps", "test"}
  ]


  def login(conn, params) do
    email = conn.params["email"]
    password = conn.params["password"]
    id = UUID.uuid4()

    if is_valid?(email, password) do
      conn
      |> put_session(:auth_token, id)
      |> json(%{
        status: "ok",
        message: "Logged in.",
        auth_token: id})
    else
      conn
      |> json(%{
        status: "error",
        message: "Authentication failed."})
    end
  end


  def is_valid?(email, password), do: {email, password} in @accs
end
