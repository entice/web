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
    get "/chat/:chat",   PageController, :chat
  end


  pipeline :api do
    plug :accepts, ~w(json)
    plug :fetch_session
    plug :fetch_flash
  end

  # API routes
  scope "/api", Entice.Web do
    pipe_through :api

    post "/login",  AuthController, :login
    post "/logout", AuthController, :logout

    get  "/char",   CharController, :list
    post "/char",   CharController, :create

    get  "/maps",       DocuController, :maps
    get  "/skills",     DocuController, :skills
    get  "/skills/:id", DocuController, :skills

    get  "/token/area",   TokenController, :area_transfer_token
    get  "/token/social", TokenController, :social_transfer_token
  end


  # Websocket channels
  socket "/ws" do
    channel "area:*", Entice.Web.AreaChannel
    channel "social:*", Entice.Web.SocialChannel
  end
end
