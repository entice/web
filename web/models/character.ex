defmodule Entice.Web.Character do
  use Ecto.Model
  use Ecto.Model.Callbacks
  alias Entice.Skills
  alias Entice.Web.Character

  schema "characters" do
    field :name,             :string
    field :available_skills, :string, default: "3FF"
    field :skillbar,        {:array, :integer}, default: [0, 0, 0, 0, 0, 0, 0, 0]
    field :profession,       :integer, default: 1
    field :campaign,         :integer, default: 0
    field :sex,              :integer, default: 1
    field :height,           :integer, default: 0
    field :skin_color,       :integer, default: 3
    field :hair_color,       :integer, default: 0
    field :hairstyle,        :integer, default: 7
    field :face,             :integer, default: 30
    belongs_to :account, Entice.Web.Account
  end

  after_load :set_skills

  def set_skills(character),
  do: %Character{character | available_skills: :erlang.integer_to_list(Skills.max_unlocked_skills, 16) |> to_string}
end

