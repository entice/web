defmodule Entice.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :entice_web


  socket "/socket", Entice.Web.Socket


  plug Plug.Static,
    at: "/", from: :entice_web, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

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

  plug Entice.Web.Router


  # Helpers that are not offered by phoenix by default

  def subscribers(topic),
  do: Phoenix.PubSub.subscribers(@pubsub_server, topic)

  def plain_broadcast(topic, message),
  do: Phoenix.PubSub.broadcast(@pubsub_server, topic, message)

  def plain_broadcast_from(topic, message),
  do: plain_broadcast_from(self, topic, message)

  def plain_broadcast_from(pid, topic, message),
  do: Phoenix.PubSub.broadcast_from(@pubsub_server, pid, topic, message)
end
