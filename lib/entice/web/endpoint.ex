defmodule Entice.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :entice_web

  plug Plug.Static,
    at: "/", from: :entice_web

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
end
