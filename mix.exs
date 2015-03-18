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
    [{:entice_logic, github: "entice/logic", ref: "cb0a795f448c7d9f7dd5bfd95d069e74d6adb501"},
     {:entice_entity, github: "entice/entity", ref: "05846160142df4d8c20b19b5aca55b9ba748d973"},
     {:entice_skill, github: "entice/skill", ref: "952c8f8ea2a36fb566f2813ffdd1813325142af8"},
     {:entice_utils, github: "entice/utils", ref: "6fc57359f452589b2ea1326f1343d6f8935f4245"},
     {:phoenix, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:postgrex, ">= 0.0.0"},
     {:ecto, "~> 0.4"},
     {:uuid, "~> 0.1.5"}] # https://github.com/zyro/elixir-uuid
  end
end
