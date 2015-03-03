defmodule Entice.Web.Queries do
  alias Entice.Web.Account
  import Ecto.Query

  def all_accounts do
    query = from a in Entice.Web.Account,
         select: a
    Entice.Web.Repo.all(query)
  end

  def get_account(email, password) do
    query = from a in Entice.Web.Account,
          where: a.email == ^email and a.password == ^password,
        preload: :characters,
         select: a

    case Entice.Web.Repo.all(query) do
      [acc] -> {:ok, acc}
      _     -> {:error, :no_matching_account}
    end
  end

  def update_account(%Account{id: id}) do
    query = from a in Entice.Web.Account,
          where: a.id == ^id,
        preload: :characters,
         select: a

    case Entice.Web.Repo.all(query) do
      [acc] -> {:ok, acc}
      _     -> {:error, :no_matching_account}
    end
  end
end
