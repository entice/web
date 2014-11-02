# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the router
config :phoenix, EnticeServer.Router,
  url: [host: "localhost"],
  http: [port: System.get_env("PORT")],
  secret_key_base: "IdLrhlWtCQ6xUcIr3EE3lEclhFj3TM/fylt5MU9klvZKfS9zNWqfYNBedl5AO7VLQkmugNrIb7fTrCNIEtTXsA==",
  catch_errors: true,
  debug_errors: false,
  error_controller: EnticeServer.PageController

# Session configuration
config :phoenix, EnticeServer.Router,
  session: [store: :cookie,
            key: "_entice_server_key"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
