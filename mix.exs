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
    [{:entice_logic, github: "entice/logic", ref: "ce229a73ac78bac9c51f331522cbe66ae6d0f102"},
     {:entice_entity, github: "entice/entity", ref: "f1d4a05d191e7ed8cc276a404381e900b0c0aec4"},
     {:entice_skill, github: "entice/skill", ref: "951a82ecbfab5d2cae4fde278b06722cd2a069d7"},
     {:entice_utils, github: "entice/utils", ref: "f8188ac7211994f192e336844b686d96a349ad61"},
     {:cowboy, "~> 1.0"},
     {:phoenix, "~> 1.0.1"},
     {:phoenix_ecto, "~> 1.1"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.1"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:uuid, "~> 1.0"}] # https://github.com/zyro/elixir-uuid
  end
end
