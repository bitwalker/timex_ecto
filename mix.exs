defmodule TimexEcto.Mixfile do
  use Mix.Project

  @source_url "https://github.com/bitwalker/timex_ecto"
  @version "3.4.0"

  def project do
    [
      app: :timex_ecto,
      version: @version,
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [applications: [:logger, :ecto, :timex]]
  end

  defp deps do
    [
      {:timex, "~> 3.6"},
      {:ecto, "~> 2.2"},
      {:postgrex, "~> 0.13", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end

  defp package do
    [
      description: "A plugin for Ecto and Timex which allows use of Timex types with Ecto",
      files: ["lib", "mix.exs", "README.md", "LICENSE.md", "CHANGELOG.md"],
      maintainers: ["Paul Schoenfelder"],
      licenses: ["MIT"],
      links: %{
        Changelog: "https://hexdocs.pm/timex_ecto/changelog.html",
        GitHub: @source_url,
      }
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
