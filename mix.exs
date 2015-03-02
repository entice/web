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
    [{:entice_logic, github: "entice/logic", ref: "12f4ed56314310c0961addee4f54849c9339e092"},
     {:entice_entity, github: "entice/entity", ref: "88ca59ed636b321796f508273414358e9aa2a8a6"},
     {:entice_skill, github: "entice/skill", ref: "e663fc81868977c0deb6c322a4953d9a098411bf"},
     {:entice_utils, github: "entice/utils", ref: "4b743c4fe22eb4934221e69da2f50800347bcf32"},
     {:phoenix, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:postgrex, ">= 0.0.0"},
     {:ecto, "~> 0.4"},
     {:uuid, "~> 0.1.5"}] # https://github.com/zyro/elixir-uuid
  end
end
