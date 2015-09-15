defmodule Entice.Web.Queries do
  alias Entice.Web.Account
  alias Entice.Web.Invitation
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

  def get_account(email) do
    query = from a in Entice.Web.Account,
          where: a.email == ^email,
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

  def get_invite(email) do
    query = from a in Entice.Web.Invitation,
          limit: 1,
          order_by: [desc: a.createdat],
          where: a.email == ^email,
          select: a

    case Entice.Web.Repo.all(query) do
      [invite] -> {:ok, invite}
      []       -> {:error, :no_matching_invite}
      _        -> {:error, :database_inconsistent}
    end
  end

  def check_existing_account(email) do
    query = from a in Entice.Web.Account,
          where: a.email == ^email,
          select: a
    case Entice.Web.Repo.all(query) do
      [account]   -> {:ok, account}
      _         -> {:ok, :account_not_found}
    end
  end
end