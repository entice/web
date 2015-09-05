defmodule Entice.Web.Mixfile do
  use Mix.Project

  def project do
    [app: :entice_web,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: ["lib", "web"],
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [mod: {Entice.Web, []},
     applications: [:phoenix, :cowboy, :logger, :postgrex, :ecto, :entice_entity]]
  end

  defp deps do
    [{:entice_logic, github: "entice/logic", ref: "f2f56eee6326cdde1344fcfc089a997f1e88ac20"},
     {:entice_entity, github: "entice/entity", ref: "ae1686cdfc819e18d6f7fcd741096d60bd906fe0"},
     {:entice_skill, github: "entice/skill", ref: "5b083e0f1f9c91b803aaa651a71a48a42989dace"},
     {:entice_utils, github: "entice/utils", ref: "f8188ac7211994f192e336844b686d96a349ad61"},
     {:cowboy, "~> 1.0"},
     {:phoenix, "~> 1.0"},
     {:postgrex, ">= 0.0.0"},
     #TODO {:phoenix_live_reload, "~> 0.2"},
     {:ecto, "~> 1.0"},
     {:uuid, "~> 1.0"}] # https://github.com/zyro/elixir-uuid
  end
end
