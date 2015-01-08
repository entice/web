defmodule Entice.Web.Router do
  use Phoenix.Router


  pipeline :browser do
    plug :accepts, ~w(html)
    plug :fetch_session
    plug :protect_from_forgery
    plug :fetch_flash
    # Manually inject the layout here due to non standard namespaces...
    plug :put_layout, {Entice.Web.LayoutView, "application.html"}
  end

  # Web routes
  scope "/", Entice.Web do
    pipe_through :browser # Use the default browser stack

    get "/",             PageController, :index
    get "/auth",         PageController, :auth
    get "/client/:area", PageController, :client
    get "/chat",         PageController, :chat
  end


  pipeline :api do
    plug :accepts, ~w(json)
    plug :fetch_session
  end

  # API routes
  scope "/api", Entice.Web do
    pipe_through :api

    post "/login",  AuthController, :login
    post "/logout", AuthController, :logout
  end


  # Websocket channels
  socket "/ws" do
    channel "area:*", Entice.Web.AreaChannel
    channel "chat:*", Entice.Web.ChatChannel
  end
end
