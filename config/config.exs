# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :entice_web,
  app_namespace: Entice.Web

# Configures the endpoint
config :entice_web, Entice.Web.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "2chowpvvTbXuS+loaCzcTU2RXQY1wQtCn22qrcE51+kcqSCenmMIRE7IrhC2Cwax",
  render_errors: [accepts: ~w(html json)],
  transports: [websocket_timeout: 60000],
  pubsub: [name: Entice.Web.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configure the database module
config :entice_web, Entice.Web.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  priv: "priv/repo"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
