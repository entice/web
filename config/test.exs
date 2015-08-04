use Mix.Config

config :entice_web, Entice.Web.Endpoint,
  http: [port: System.get_env("PORT") || 4001],
  server: false

config :entice_web, Entice.Web.Repo,
  database: "entice_test",
  username: "postgres",
  password: "",
  hostname: "localhost",
  priv: "priv/repo"
