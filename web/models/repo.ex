defmodule Entice.Web.Repo do
  use Ecto.Repo,
    otp_app: :entice_web,
    adapter: Ecto.Adapters.Postgres
end
