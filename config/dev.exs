use Mix.Config

config :entice_web, Entice.Web.Endpoint,
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true,
  cache_static_lookup: false

config :entice_web, Entice.Web.Repo,
  db_url: "ecto://postgres:@localhost/entice"

# Enables code reloading for development
config :phoenix, :code_reloader, true
