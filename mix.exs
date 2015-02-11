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
    [{:entice_logic, github: "entice/logic", ref: "e7085bbcfc5fb589a8a60b04dbf832b571ab3327"},
     {:entice_skill, github: "entice/skill", ref: "c4edbfcb0e0fc69431c921274259e4423afbd00c"},
     {:entice_utils, github: "entice/utils", ref: "3150853ee019d0eee44be9baf97e45ca6f0abf68"},
     {:phoenix, github: "phoenixframework/phoenix", ref: "85ea87a672d8e0410b0842e138a71510cb531d90"},
     {:cowboy, "~> 1.0"},
     {:postgrex, ">= 0.0.0"},
     {:ecto, "~> 0.4"},
     {:uuid, "~> 0.1.5"}] # https://github.com/zyro/elixir-uuid
  end
end
