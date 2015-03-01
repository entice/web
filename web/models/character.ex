defmodule Entice.Web.Character do
  use Ecto.Model

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
end

