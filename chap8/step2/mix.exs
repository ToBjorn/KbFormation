defmodule Tutokbrwstack.MixProject do
  use Mix.Project

  def project do
    [
      app: :tutokbrwstack,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:reaxt_webpack] ++ Mix.compilers,
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets, :ssl],
      mod: {TutoKBRWStack, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:reaxt, tag: "v4.0.2", github: "kbrw/reaxt"},
      {:poison, "~> 5.0"},
      {:plug_cowboy, "~> 2.4"},
      {:exfsm, git: "https://github.com/kbrw/exfsm.git"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
