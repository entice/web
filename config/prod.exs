use Mix.Config

# ## SSL Support
#
# To get SSL working, you will need to set:
#
#     https: [port: 443,
#             keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#             certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables point to a file on
# disk for the key and cert.

config :phoenix, EnticeServer.Router,
  url: [host: "entice-server-elixir.herokuapp.com"],
  http: [port: System.get_env("PORT")],
  secret_key_base: "IdLrhlWtCQ6xUcIr3EE3lEclhFj3TM/fylt5MU9klvZKfS9zNWqfYNBedl5AO7VLQkmugNrIb7fTrCNIEtTXsA=="

config :logger,
  level: :info
