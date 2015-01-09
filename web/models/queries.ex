defmodule Entice.Web.Queries do
  import Ecto.Query

  def all_users do
    query = from u in Entice.Web.Users,
         select: u
    Entice.Web.Repo.all(query)
  end

  def user_exists?(email, password) do
    query = from u in Entice.Web.Users,
          where: u.email == ^email and u.password == ^password,
         select: u
    not (Entice.Web.Repo.all(query) |> Enum.empty?)
  end
end
