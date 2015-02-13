defmodule Entice.Web do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Entice.Web.Worker, [arg1, arg2, arg3])
      worker(Entice.Web.Repo, []),
      worker(Entice.Web.Endpoint, []),
      supervisor(Entice.Entity.Supervisor, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Entice.Web.Supervisor]
    {:ok, sup} = Supervisor.start_link(children, opts)

    {:ok, sup}
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Entice.Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
