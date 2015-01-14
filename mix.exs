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
    [{:entice_area, github: "entice/area", branch: "master"},
     {:phoenix, "~> 0.8"},
     {:cowboy, "~> 1.0"},
     {:postgrex, ">= 0.0.0"},
     {:ecto, "~> 0.4"},
     {:uuid, "~> 0.1.5"}] # https://github.com/zyro/elixir-uuid
  end
end
