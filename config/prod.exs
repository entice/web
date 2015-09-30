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

# ## SSL Support
#
# To get SSL working, you will need to set:
#
#     https: [port: 443,
#             keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#             certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables point to a file on

# Finally import the config/prod.secret.exs
# which should be versioned separately.
import_config "prod.secret.exs"
