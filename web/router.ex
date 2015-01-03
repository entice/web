defmodule Entice.Web.Router do
  use Phoenix.Router
  use Phoenix.Router.Socket, mount: "/ws"

  pipeline :browser do
    plug :accepts, ~w(html)
    plug :fetch_session
    plug :fetch_flash
    plug :put_layout, {Entice.Web.LayoutView, "application.html"}
  end

  pipeline :api do
    plug :accepts, ~w(json)
    plug :fetch_session
  end


  # Web routes
  scope "/", Entice.Web do
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
  channel "chat", Entice.Web.ChatChannel
end
