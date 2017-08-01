defmodule ApmIssues.Mixfile do
  use Mix.Project

  def project do
    [
      app: :apm_issues,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger],
     mod: {ApmIssues, []}]
  end

  defp deps do
    [
      {:poison, "~> 2.0"},
      { :uuid, "~> 1.1" }
    ]
  end
end
