defmodule EnticeServer.Router do
  use Phoenix.Router

  # Simple HTML pipeline
  pipeline :browser do
    plug :accepts, ~w(html)
    plug :fetch_session
  end

  # Simple JSON api pipeline
  pipeline :api do
    plug :accepts, ~w(json)
  end


  scope "/" do
    pipe_through :browser # Use the default browser stack

    get "/", EnticeServer.PageController, :index
  end


  scope "/api" do
    pipe_through :api
  end
end
