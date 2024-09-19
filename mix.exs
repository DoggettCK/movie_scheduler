defmodule MovieScheduler.MixProject do
  use Mix.Project

  def project do
    [
      app: :movie_scheduler,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:csv, "~> 3.2"},
      {:date_time_parser, "~> 1.2"},
      {:httpoison, "~> 2.2"},
      {:jason, "~> 1.4"},
      {:mix_test_watch, "~> 1.2", only: [:dev], runtime: false},
      {:scribe, "~> 0.10"}
    ]
  end
end
