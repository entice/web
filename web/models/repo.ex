defmodule Entice.Web.Repo do
    use Ecto.Repo,
      otp_app: :entice_web,
      adapter: Ecto.Adapters.Postgres

    def priv do
      app_dir(:entice_web, "priv/repo")
    end
end
