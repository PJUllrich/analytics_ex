defmodule AnalyticsEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :analytics_ex,
      description:
        "A library tracking how many visitors a Phoenix-based application receives per day without collecting any data from the user",
      version: "0.2.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {AnalyticsEx.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix_live_dashboard, "~> 0.4"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/PJUllrich/analytics_ex"}
    ]
  end
end
