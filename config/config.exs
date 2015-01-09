# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :entice_web,
  phoenix_namespace: Entice.Web

# Configures the endpoint
config :entice_web, Entice.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Ja11ias2sS4WOrq0DBR3HctuznRaS9rdGdhqKy2dE1/Cd66X8u/p8YqJfu5mSNTO",
  debug_errors: false

# Configure the database module
config :entice_web, Entice.Web.Repo,
  db_url: System.get_env("DATABASE_URL")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
