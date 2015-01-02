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
  scope "/", EnticeServer do
    pipe_through :browser # Use the default browser stack

    get "/",     PageController, :index
    get "/auth", PageController, :auth
    get "/test", PageController, :test
    get "/chat", PageController, :chat
  end


  # API routes
  scope "/api" do
    pipe_through :api
  end


  # Websocket channels
  channel "chat", EnticeServer.ChatChannel
end
