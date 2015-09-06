defmodule Entice.Web.DocuController do
  use Entice.Web.Web, :controller
  alias Entice.Logic.Area
  alias Entice.Skills

  plug :ensure_login


  def maps(conn, _params) do
    maps = Area.get_maps
    |> Enum.filter(&(&1 != Lobby and &1 != Transfer))
    |> Enum.map(&(&1.underscore_name))

    conn |> json ok(%{
      message: "All maps...",
      maps: maps})
  end


  def skills(conn, %{"id" => id}) do
    case id |> String.to_integer |> Skills.get_skill do
      {:error, m} -> conn |> json error(%{message: m})
      {:ok, s}    ->
        conn |> json ok(%{
          message: "Requested skill...",
          skill: %{
            id: s.id,
            name: s.underscore_name,
            description: s.description}})
    end
  end


  def skills(conn, _params) do
    sk = Skills.get_skills
    |> Enum.map(&(%{
      id: &1.id,
      name: &1.skill.underscore_name,
      description: &1.skill.description}))

    conn |> json ok(%{
      message: "All skills...",
      skills: sk})
  end
end
