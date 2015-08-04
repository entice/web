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
    [{:entice_logic, github: "entice/logic", ref: "fbd1f1f97959c587b002cc8d4d09a079588f737f"},
     {:entice_entity, github: "entice/entity", ref: "f733dc15a16d68d95f5463499c619030872c7ff8"},
     {:entice_skill, github: "entice/skill", ref: "df66becfdfa24dad4b7f09f03954328bb4d12ccc"},
     {:entice_utils, github: "entice/utils", ref: "739a10e6a328582a438c42d01dac9c87af914730"},
     {:phoenix, github: "phoenixframework/phoenix", ref: "c422c41890a74186e008fd9939e679c4ffee03d7"},
     {:cowboy, "~> 1.0"},
     {:postgrex, ">= 0.0.0"},
     #TODO {:phoenix_live_reload, "~> 0.2"},
     {:ecto, "~> 0.4"},
     {:uuid, "~> 1.0"}] # https://github.com/zyro/elixir-uuid
  end
end
