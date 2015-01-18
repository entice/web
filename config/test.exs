use Mix.Config

config :entice_web, Entice.Web.Endpoint,
  http: [port: System.get_env("PORT") || 4001]

config :entice_web, Entice.Web.Repo,
  database: "entice_test",
  username: "postgres",
  password: "",
  hostname: "localhost",
  priv: "priv/repo"

# Enables code reloading for test
config :phoenix, :code_reloader, true
