defmodule SellercenterReadmeIo.Mixfile do
  use Mix.Project

  def application do
    [
      applications: [
        :httpoison,
        :timex
      ]
    ]
  end

  def deps do
    [
      {:credo, "~> 0.4"},
      {:dogma, "~> 0.1"},
      {:exjsx, "~> 3.2"},
      {:httpoison, "~> 0.9.0"},
      {:timex, "~> 3.0"}
    ]
  end

  def project do
    [
      app: :sellercenter_readme_io,
      build_embedded: Mix.env == :prod,
      deps: deps(),
      elixir: "~> 1.3",
      start_permanent: Mix.env == :prod,
      version: "0.1.0"
    ]
  end
end
