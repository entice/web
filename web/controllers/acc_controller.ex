defmodule Entice.Web.AccountController do
  use Phoenix.Controller
  alias Entice.Web.Account
  import Entice.Web.ControllerHelper

  plug :action


  def create(conn, _params) do
    email = conn.params["email"]
	password = conn.params["password"]

	account = %Account{email: email, password: password}
		|> Entice.Web.Repo.insert

	conn |> json ok(%{
		message: "Account created!"})
  end
end