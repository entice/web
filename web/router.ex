defmodule Entice.Web.Router do
  use Entice.Web.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    # Manually inject the layout here due to non standard namespaces...
    plug :put_layout, {Entice.Web.LayoutView, "app.html"}
  end

  # Web routes
  scope "/", Entice.Web do
    pipe_through :browser # Use the default browser stack

    get "/",             PageController, :index
    get "/auth",         PageController, :auth
    get "/client/:map",  PageController, :client
    get "/account",      PageController, :account
  end


  pipeline :api do
    plug :accepts, ["json"]
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

    post "/account",      AccountController, :create
  end
end
