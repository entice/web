defmodule Entice.Web do
  use Application
  alias Entice.Logic.Npc

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(Entice.Web.Endpoint, []),
      # Start the Ecto repository
      worker(Entice.Web.Repo, []),
      worker(Entice.Web.Client.Server, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Entice.Web.Supervisor]
    result = Supervisor.start_link(children, opts)

    Npc.spawn_all()
    result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Entice.Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
