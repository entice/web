defmodule Entice.Web.Queries do
  import Ecto.Query

  def all_accounts do
    query = from a in Entice.Web.Account,
         select: a
    Entice.Web.Repo.all(query)
  end

  def account_exists?(email, password) do
    query = from a in Entice.Web.Account,
          where: a.email == ^email and a.password == ^password,
         select: a
    not (Entice.Web.Repo.all(query) |> Enum.empty?)
  end
end
