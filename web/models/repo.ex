defmodule Entice.Web.Repo do
    use Ecto.Repo, adapter: Ecto.Adapters.Postgres

    def conf do
      Application.get_env(:entice_web, __MODULE__)
      |> Keyword.get(:db_url)
      |> parse_url
    end

    def priv do
      app_dir(:entice_web, "priv/repo")
    end
end
