use Mix.Config

config :entice_web, Entice.Web.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [
    host: (System.get_env("HOST_NAME") || "to.entice.so"),
    port: (System.get_env("HOST_PORT") || 80)],
  cache_static_manifest: "priv/static/manifest.json"

# Do not print debug messages in production
config :logger,
  level: :info
