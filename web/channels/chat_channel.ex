defmodule Entice.Web.ChatChannel do
  use Phoenix.Channel
  alias Entice.Web.Clients


  def join("chat:" <> chat_channel, %{"client_id" => id, "transfer_token" => token, "char_name" => name}, socket) do
    {:ok, ^token} = Clients.get_transfer_token(id)
    {:ok, char}   = Clients.get_char(id, name)
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
