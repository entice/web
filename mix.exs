defmodule Entice.Web.Mixfile do
  use Mix.Project

  def project do
    [app: :entice_web,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [mod: {Entice.Web, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger,
                    :phoenix_ecto, :postgrex, :entice_entity]]
  end

  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp deps do
    [{:entice_logic, github: "entice/logic", ref: "62cc6cb45b4d430e44f6c3f5ac0daa0b598d3566"},
     {:entice_entity, github: "entice/entity", ref: "abd47e4bf5cc97d69c0c332d9559c63718348c0e"},
     {:entice_skill, github: "entice/skill", ref: "7fca03ba881edc53c65db8fb2703f69b3cba3acd"},
     {:entice_utils, github: "entice/utils", ref: "45fa9369284f92857c4436251a6b995c5d014680"},
     {:cowboy, "~> 1.0"},
     {:phoenix, "~> 1.0.1"},
     {:phoenix_ecto, "~> 1.1"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.1"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:uuid, "~> 1.0"}] # https://github.com/zyro/elixir-uuid
  end
end
