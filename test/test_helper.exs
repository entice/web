Code.require_file "test_factories.exs", __DIR__

Entice.Test.Factories.Counter.start_link

ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(Entice.Web.Repo, :manual)
