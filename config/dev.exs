use Mix.Config

config :entice_web, Entice.Web.Endpoint,
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  watchers: [],
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}]]

config :entice_web, Entice.Web.Repo,
  database: "entice",
  username: "postgres",
  password: "",
  hostname: "localhost",
  priv: "priv/repo"
