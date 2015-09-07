defmodule Entice.Web.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used as:

      use Entice.Web.Web, :controller
      use Entice.Web.Web, :view
  """


  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end


  def router do
    quote do
      use Phoenix.Router
    end
  end


  def model do
    quote do
      use Ecto.Model
    end
  end


  def view do
    quote do
      use Phoenix.View, namespace: Entice.Web, root: "web/templates"

      # Import all HTML functions (forms, tags, etc)
      use Phoenix.HTML
      import Phoenix.Controller, only: [get_flash: 2]

      # Import helpers
      import Entice.Web.Router.Helpers
      import Entice.Web.Client

      # Functions defined here are available to all other views/templates
      def title, do: "... entice server ..."
      def email(conn), do: Plug.Conn.get_session(conn, :email)
    end
  end


  def controller do
    quote do
      use Phoenix.Controller
      alias Entice.Web.Client
      alias Entice.Web.Repo
      import Entice.Web.Router.Helpers

      @doc "Use as plug to filter for logged in clients"
      def ensure_login(conn, _opts) do
        case Client.logged_in?(get_session(conn, :client_id)) do
          true  -> conn
          false -> conn
            |> put_flash(:message, "You need to login.")
            |> redirect(to: "/")
            |> halt
        end
      end

      @doc "Simple API message helper, returns JSON with OK status"
      def ok(msg), do: Map.merge(%{status: :ok}, msg)

      @doc "Simple API message helper, returns JSON with ERROR status"
      def error(msg), do: Map.merge(%{status: :error}, msg)
    end
  end


  def channel do
    quote do
      use Phoenix.Channel
      alias Entice.Logic.Area
      alias Entice.Web.Token
      import Phoenix.Socket
      import Phoenix.Naming

      def try_join(client_id, token, map, socket) do
        try_join_internal(
          client_id, token, socket,
          Token.get_token(client_id),
          Area.get_map(camelize(map)))
      end

      defp try_join_internal(
          client_id, token, socket,
          {:ok, token, :entity, %{entity_id: entity_id, map: map_mod, char: char}},
          {:ok, map_mod}) do
        socket = socket
          |> set_map(map_mod)
          |> set_entity_id(entity_id)
          |> set_client_id(client_id)
          |> set_character(char)
          |> set_name(char.name)
        {:ok, socket}
      end
      defp try_join_internal(_client_id, _token, _socket, _token_return, _map_return),
      do: :ignore

      def set_map(socket, map),             do: socket |> assign(:map, map)
      def map(socket),                      do: socket.assigns[:map]

      def set_entity_id(socket, entity_id), do: socket |> assign(:entity_id, entity_id)
      def entity_id(socket),                do: socket.assigns[:entity_id]

      def set_client_id(socket, client_id), do: socket |> assign(:client_id, client_id)
      def client_id(socket),                do: socket.assigns[:client_id]

      def set_character(socket, character), do: socket |> assign(:character, character)
      def character(socket),                do: socket.assigns[:character]

      def set_name(socket, name),           do: socket |> assign(:name, name)
      def name(socket),                     do: socket.assigns[:name]
    end
  end
end
