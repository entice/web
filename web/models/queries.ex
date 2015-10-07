defmodule Entice.Web.Queries do
  alias Entice.Web.Account
  alias Entice.Web.Character
  alias Entice.Web.Invitation
  alias Entice.Web.Friend
  alias Entice.Web.Repo
  import Ecto.Query
  import ExUnit.Assertions

  def all_accounts do
    query = from a in Account,
         select: a
    Repo.all(query)
  end

  def get_account_id(name) do
    query = from char in Character,
          where: char.name == ^name,
         select: char.account_id

    case Repo.all(query) do
      [account_id] -> {:ok, account_id}
      _            -> {:error, :no_matching_character}
    end
  end

  def get_account_by_name(name) do
    case get_account_id(name) do
      {:ok, account_id} ->
        account = Entice.Web.Repo.get(Entice.Web.Account, account_id)
        assert account != nil, "There should never be a character without an account." #Right?
        {:ok, account}
      _ -> {:error, :no_matching_character}
    end
  end

  def get_account(email, password) do
    query = from a in Account,
          where: a.email == ^email and a.password == ^password,
        preload: :characters,
         select: a

    case Repo.all(query) do
      [acc] ->
        friends = get_friends(acc.id)
        {:ok, %Account{acc | friends: friends}}
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
      [acc] ->
        friends = get_friends(acc.id)
        {:ok, %Account{acc | friends: friends}}
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

  def add_friend(account, friend_account, base_name) do
    %Friend{base_name: base_name, friend_account: friend_account, account: account, friend_account_id: friend_account.id, account_id: account.id}
      |> Repo.insert
  end

  def get_friend_by_base_name(account_id, base_name), do: get_friend(account_id, :base_name, base_name)
  def get_friend_by_friend_account_id(account_id, friend_account_id), do: get_friend(account_id, :friend_account_id, friend_account_id)

  def get_friend(account_id, key_atom, key) do
    query = case key_atom do
      :base_name ->
        from f in Entice.Web.Friend,
          where: f.account_id == ^account_id and f.base_name == ^key,
          select: f
      :friend_account_id ->
        from f in Entice.Web.Friend,
          where: f.account_id == ^account_id and f.friend_account_id == ^key,
          select: f
    end
    case Repo.all(query) do
      [friend] -> {:ok, friend}
      _     -> {:error, :no_matching_friend}
    end
  end

  def get_friends(account_id) do
    query = from f in Friend,
          where: f.account_id == ^account_id,
        preload: [:friend_account],
         select: f

    Repo.all(query)
  end
end
