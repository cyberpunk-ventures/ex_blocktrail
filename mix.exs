defmodule BlocktrailCom.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_blocktrail,
     version: "0.2.2",
     elixir: "~> 1.3",
     description: description,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison, :poison, :exconstructor, :vex, :yuri]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, ">= 0.0.0"},
      {:poison, ">= 2.0.0"},
      {:exconstructor, ">= 1.0.0"},
      {:vex, ">= 0.0.0"},
      {:yuri, ">= 1.0.0"}
    ]
  end

  defp package do
    [# These are the default files included in the package
     name: :ex_blocktrail,
     files: ["lib", "mix.exs", "LICENSE*"],
     maintainers: ["ontofractal"],
     licenses: ["MIT"],
     links: %{}]
  end

  defp description do
   "WIP. Elixir wrapper for blocktrail.com Bitcoin api and some utility functions."
  end
end

