use Mix.Config

config :entice_server, EnticeServer.Endpoint,
  http: [port: System.get_env("PORT") || 4001]
