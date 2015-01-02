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

config :entice_server, EnticeServer.Endpoint,
  url: [host: "entice-server-elixir.herokuapp.com"],
  http: [port: System.get_env("PORT")],
  secret_key_base: "Ja11ias2sS4WOrq0DBR3HctuznRaS9rdGdhqKy2dE1/Cd66X8u/p8YqJfu5mSNTO"

config :logger,
  level: :info
