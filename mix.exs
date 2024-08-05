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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:csv, "~> 3.2"},
      {:jason, "~> 1.4"},
      {:mix_test_watch, "~> 1.2"},
      {:scribe, "~> 0.10"},
    ]
  end
end
