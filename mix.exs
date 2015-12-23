defmodule Entice.Web.Mixfile do
  use Mix.Project

  def project do
    [app: :entice_web,
     version: "0.0.1",
     elixir: "~> 1.1",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  def application do
    [mod: {Entice.Web, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :postgrex, :entice_entity]]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp deps do
    [{:entice_logic, github: "entice/logic", ref: "daa0a7b2a8d9b5e7e662e947788103154f3ffc16"},
     {:entice_entity, github: "entice/entity", ref: "14d1df1b03d4002c05df78ab9240acbbd696ff8c"},
     {:entice_utils, github: "entice/utils", ref: "e80039a439753d743635b0a67b78fa04329f8930"},
     {:cowboy, "~> 1.0"},
     {:phoenix, "~> 1.1"},
     {:phoenix_ecto, "~> 2.0"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.3"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.9"},
     {:uuid, "~> 1.0"}] # https://github.com/zyro/elixir-uuid
  end

  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"]]
  end
end
