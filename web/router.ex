defmodule EnticeServer.Router do
  use Phoenix.Router
  use Phoenix.Router.Socket, mount: "/ws"

  pipeline :browser do
    plug :accepts, ~w(html)
    plug :fetch_session
  end

  pipeline :api do
    plug :accepts, ~w(json)
  end


  # Web routes
  scope "/" do
    pipe_through :browser # Use the default browser stack

    get "/", EnticeServer.PageController, :index
    get "/auth", EnticeServer.PageController, :auth
    get "/test", EnticeServer.PageController, :test
    get "/chat", EnticeServer.PageController, :chat
  end


  # API routes
  scope "/api" do
    pipe_through :api
  end


  # Websocket channels
  channel "chat", EnticeServer.ChatChannel
end
