defmodule Entice.Web.DocuController do
  use Phoenix.Controller
  use Entice.Area
  alias Entice.Area
  import Entice.Web.Auth
  import Entice.Web.ApiMessage

  plug :ensure_login
  plug :action


  def maps(conn, _params) do
    maps = Area.get_maps
    |> Enum.filter(&(&1 != Lobby and &1 != Transfer))
    |> Enum.map(&(&1.underscore_name))

    conn |> json ok(%{
      message: "All maps...",
      maps: maps})
  end
end
