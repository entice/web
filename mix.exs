defmodule Entice.Web.Mixfile do
  use Mix.Project

  def project do
    [app: :entice_web,
     version: "0.0.1",
     elixir: "~> 1.1",
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
    [{:entice_logic, github: "entice/logic", ref: "04c5ccc9c0fda1372880f73a42fef99d8e6fda88"},
     {:entice_entity, github: "entice/entity", ref: "6d952892c56c2a8c636baca143e64f43c553e1b9"},
     {:entice_utils, github: "entice/utils", ref: "74ce9f8a2e2fd7766263e193bffba4901aa425a8"},
     {:cowboy, "~> 1.0"},
     {:phoenix, "~> 1.0.3"},
     {:phoenix_ecto, "~> 1.2"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.2"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:uuid, "~> 1.0"}] # https://github.com/zyro/elixir-uuid
  end
end
