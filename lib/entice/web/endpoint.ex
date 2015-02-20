defmodule Entice.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :entice_web

  plug Plug.Static,
    at: "/", from: :entice_web,
    only: ~w(css images js favicon.ico robots.txt)

  plug Plug.Logger

  # Code reloading will only work if the :code_reloader key of
  # the :phoenix application is set to true in your config file.
  plug Phoenix.CodeReloader

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "entice_session",
    signing_salt: "wZg9FGRp",
    encryption_salt: "KzX0FbQY"

  plug :router, Entice.Web.Router


  def subscribe(pid, topic),
  do: Phoenix.PubSub.subscribe(@pubsub_server, pid, topic)

  def subscribers(topic),
  do: Phoenix.PubSub.subscribers(@pubsub_server, topic)

  def unsubscribe(pid, topic),
  do: Phoenix.PubSub.unsubscribe(@pubsub_server, pid, topic)

  def entity_broadcast(topic, message),
  do: Phoenix.PubSub.broadcast(@pubsub_server, topic, message)

  def entity_broadcast_from(topic, message),
  do: Phoenix.PubSub.broadcast_from(@pubsub_server, self, topic, message)
end
