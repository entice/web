defmodule Entice.Web.Character do
  use Entice.Web.Web, :schema
  alias Entice.Logic.Skills

  schema "characters" do
    field :name,             :string
    field :available_skills, :string, default: (:erlang.integer_to_list(Skills.max_unlocked_skills, 16) |> to_string)
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
    timestamps
  end


  def changeset_skillbar(character, skillbar \\ [0, 0, 0, 0, 0, 0, 0, 0]) do
    character
    |> cast(%{skillbar: skillbar}, [:skillbar])
    |> validate_required([:skillbar])
  end


  def changeset_char_create(character, params \\ :invalid) do
    character
    |> cast(params, [:name, :account_id, :available_skills, :skillbar, :profession, :campaign, :sex, :height, :skin_color, :hair_color, :hairstyle, :face])
    |> validate_required([:name, :account_id])
    |> validate_inclusion(:profession, 0..20)
    |> validate_inclusion(:campaign, 0..5)
    |> validate_inclusion(:sex, 0..5)
    |> validate_inclusion(:height, 0..30)
    |> validate_inclusion(:skin_color, 0..30)
    |> validate_inclusion(:hair_color, 0..35)
    |> validate_inclusion(:hairstyle, 0..35)
    |> validate_inclusion(:face, 0..35)
    |> assoc_constraint(:account)
    |> unique_constraint(:name)
  end
end

