defmodule Entice.Web.SocialChannel do
  use Phoenix.Channel
  alias Entice.Web.Clients


  def join("social:" <> room, %{"client_id" => id, "transfer_token" => token}, socket) do
    {:ok, ^token, :social, %{room: ^room, char: char}} = Clients.get_transfer_token(id)
    Clients.delete_transfer_token(id)

    socket = socket
      |> set_name(char.name)

    socket |> reply("join:ok", %{})
    {:ok, socket}
  end

  def handle_in("message", %{"text" => t}, socket) do
    broadcast(socket, "message", %{text: t, sender: socket |> name})
  end

  def handle_in("emote", %{"action" => a}, socket) do
    broadcast(socket, "emote", %{action: a, sender: socket |> name})
  end

  # Internal

  defp set_name(socket, name), do: socket |> assign(:name, name)
  defp name(socket),           do: socket.assigns[:name]
end
