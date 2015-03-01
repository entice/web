defmodule Entice.Web.Mixfile do
  use Mix.Project

  def project do
    [app: :entice_web,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: ["lib", "web"],
     compilers: [:phoenix] ++ Mix.compilers,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Entice.Web, []},
     applications: [:phoenix, :cowboy, :logger, :postgrex, :ecto, :entice_entity]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:entice_logic, github: "entice/logic", ref: "2bfd20786aa70a17596a3df1d9566e8e6095b563"},
     {:entice_entity, github: "entice/entity", ref: "06adfb826f45a3a4c74b9b93a6c1abf094170e1f"},
     {:entice_skill, github: "entice/skill", ref: "c4edbfcb0e0fc69431c921274259e4423afbd00c"},
     {:entice_utils, github: "entice/utils", ref: "4b743c4fe22eb4934221e69da2f50800347bcf32"},
     {:phoenix, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:postgrex, ">= 0.0.0"},
     {:ecto, "~> 0.4"},
     {:uuid, "~> 0.1.5"}] # https://github.com/zyro/elixir-uuid
  end
end
