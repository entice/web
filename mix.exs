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
     applications: [:phoenix, :cowboy, :logger, :postgrex, :ecto]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:entice_logic, github: "entice/logic", ref: "2b1e9bdf9cab4e9353d35d8266aa0c96b5fada45"},
     {:entice_entity, github: "entice/entity", ref: "db080ad74408471f1c71b55c5d61d3cf00b28040"},
     {:entice_skill, github: "entice/skill", ref: "c4edbfcb0e0fc69431c921274259e4423afbd00c"},
     {:entice_utils, github: "entice/utils", ref: "4b743c4fe22eb4934221e69da2f50800347bcf32"},
     {:phoenix, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:postgrex, ">= 0.0.0"},
     {:ecto, "~> 0.4"},
     {:uuid, "~> 0.1.5"}] # https://github.com/zyro/elixir-uuid
  end
end
