defmodule Entice.Web.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias Entice.Web.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 2]

      import Entice.Web.Router.Helpers

      # The default endpoint for testing
      @endpoint Entice.Web.Endpoint

      @opts Entice.Web.Router.init([])

      def with_session(conn, context) do
        session_opts = Plug.Session.init(store: :cookie,
          key: "_app",
          encryption_salt: "abc",
          signing_salt: "abc")

        {:ok, id} = Entice.Web.Client.log_in(context.email, context.password)
        conn
        |> Map.put(:secret_key_base, String.duplicate("abcdefgh", 8))
        |> Plug.Session.call(session_opts)
        |> Plug.Conn.fetch_session()
        |> put_session(:email, context.email)
        |> put_session(:client_id, id)
      end

      def fetch_route(req, route, context) do
        conn = conn(req, route, context.params)
        |> with_session(context)
        conn = Entice.Web.Router.call(conn, @opts)
        Poison.decode(conn.resp_body)
      end
    end
  end

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(Entice.Web.Repo, [])
    end

    :ok
  end
end
