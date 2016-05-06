defmodule Entice.Web.Mixfile do
  use Mix.Project

  def project do
    [app: :entice_web,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  def application do
    [mod: {Entice.Web, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :postgrex, :entice_entity]]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp deps do
    [{:entice_logic, github: "entice/logic", ref: "e3a833c9197edbdb6c43ebffb02a2705ca13bad3"},
     {:entice_entity, github: "entice/entity", ref: "c26f6f77ae650e25e6cd2ffea8aae46b7d83966a"},
     {:entice_utils, github: "entice/utils", ref: "79ead4dca77324b4c24f584468edbaff2029eeab"},
     {:cowboy, "~> 1.0"},
     {:phoenix, "~> 1.2.0-rc"},
     {:phoenix_pubsub, "~> 1.0.0-rc"},
     {:phoenix_ecto, "~> 3.0.0-rc"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.3"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.9"},
     {:uuid, "~> 1.0"}] # https://github.com/zyro/elixir-uuid
  end

  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test":  ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
