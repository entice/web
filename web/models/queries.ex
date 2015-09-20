defmodule Entice.Web.Queries do
  alias Entice.Web.Account
  alias Entice.Web.Invitation
  alias Entice.Web.Repo
  import Ecto.Query

  def all_accounts do
    query = from a in Account,
         select: a
    Repo.all(query)
  end

  def get_account(email, password) do
    query = from a in Account,
          where: a.email == ^email and a.password == ^password,
        preload: :characters,
         select: a

    case Repo.all(query) do
      [acc] -> {:ok, acc}
      _     -> {:error, :no_matching_account}
    end
  end

  def get_account(email) do
    query = from a in Account,
          where: a.email == ^email,
         select: a

    case Repo.all(query) do
      [acc] -> {:ok, acc}
      _     -> {:error, :account_not_found}
    end
  end

  def update_account(%Account{id: id}) do
    query = from a in Account,
          where: a.id == ^id,
        preload: :characters,
         select: a

    case Repo.all(query) do
      [acc] -> {:ok, acc}
      _     -> {:error, :no_matching_account}
    end
  end

  def get_invite(email) do
    query = from a in Invitation,
          limit: 1,
          where: a.email == ^email,
          select: a

    case Repo.all(query) do
      [invite] -> {:ok, invite}
      []       -> {:error, :no_matching_invite}
      _        -> {:error, :database_inconsistent}
    end
  end
  
end
