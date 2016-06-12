defmodule TimexEcto.Mixfile do
  use Mix.Project

  def project do
    [app: :timex_ecto,
     version: "1.1.3",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     package: package]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :ecto, :timex]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:timex, "~> 2.1"},
     {:ecto, "~> 1.1 or ~> 2.0 or ~> 2.0.0-rc3"},
     {:earmark, ">= 0.0.0", only: :dev},
     {:ex_doc, "~> 0.10", only: :dev}]
  end

  defp package do
    [ files: ["lib", "priv", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Paul Schoenfelder"],
      licenses: ["MIT"],
      description: "A plugin for Ecto and Timex which allows use of Timex types with Ecto",
      links: %{ "GitHub": "https://github.com/bitwalker/timex_ecto", "Docs": "https://timex.readme.io" } ]
  end
end
