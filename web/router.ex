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
    get "/client/:map",  PageController, :client
  end


  pipeline :api do
    plug :accepts, ~w(json)
    plug :fetch_session
    plug :fetch_flash
  end

  # API routes
  scope "/api", Entice.Web do
    pipe_through :api

    post "/login",        AuthController, :login
    post "/logout",       AuthController, :logout

    get  "/char",         CharController, :list
    post "/char",         CharController, :create

    get  "/maps",         DocuController, :maps
    get  "/skills",       DocuController, :skills
    get  "/skills/:id",   DocuController, :skills

    get  "/token/entity", TokenController, :entity_token
  end


  # Websocket channels
  socket "/ws", Entice.Web do
    channel "entity:*",   EntityChannel
    channel "group:*",    GroupChannel
    channel "movement:*", MovementChannel
    channel "skill:*",    SkillChannel
    channel "social:*",   SocialChannel
  end
end
