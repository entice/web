use Mix.Config

config :entice_web, Entice.Web.Endpoint,
  http: [port: System.get_env("PORT") || 4001]

config :entice_web, Entice.Web.Repo,
  db_url: "ecto://postgres:@localhost/entice_test"

# Enables code reloading for test
config :phoenix, :code_reloader, true
