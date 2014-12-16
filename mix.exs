defmodule Simplex.Mixfile do
  use Mix.Project

  def project do
    [app: :simplex,
     version: version,
     test_coverage: [tool: ExCoveralls],
     elixir: "~> 1.0.0",
     deps: deps,
     package: [
       contributors: ["Adam Kittelson"],
       licenses: ["MIT"],
       links: %{ github: "https://github.com/adamkittelson/simplex" },
       files: ["lib/*", "mix.exs", "README.md", "LICENSE.md", "CHANGELOG.md", "VERSION.yml"]
     ],
     description: "An Elixir library for interacting with the Amazon SimpleDB API."]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :httpotion]]
  end

  # Dependencies can be hex.pm packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1"}
  #
  # Type `mix help deps` for more examples and options
  def deps do
    [
      {:timex, "~> 0.12.5"},
      {:httpotion, "~> 1.0.0"},
      {:ibrowse, github: "cmullaparthi/ibrowse", tag: "v4.1.0"},
      {:sweet_xml, "~> 0.1.1"},
      {:poison, "~> 1.2.0"},
      {:excoveralls, "~> 0.3", only: [:dev, :test]},
      {:exvcr, "~> 0.3.5", only: [:dev, :test], optional: true}
    ]
  end

  defp version do
     ~r/[0-9]+/
     |> Regex.scan(File.read!("VERSION.yml"))
     |> List.flatten
     |> Enum.join(".")
  end
end
