defmodule Simplex.Mixfile do
  use Mix.Project

  def project do
    [app: :simplex,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :httpoison]]
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
  defp deps do
    [
      {:timex, "~> 0.12.5"},
      {:erlsha2,  github: "vinoski/erlsha2"},
      {:httpoison, "~> 0.4.2"},
      {:sweet_xml, "~> 0.1.1"}
    ]
  end
end
