defmodule Entice.Web.AccountController do
  use Entice.Web.Web, :controller
  alias Entice.Web.Account

  def create(conn, _params) do
    email = conn.params["email"]
    password = conn.params["password"]

    %Account{email: email, password: password}
    |> Entice.Web.Repo.insert

    conn |> json ok(%{message: "Account created!"})
  end
end
