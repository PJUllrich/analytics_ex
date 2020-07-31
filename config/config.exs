import Config

config :analytics_ex,
  ecto_repos: [AnalyticsEx.Repo]

import_config "#{Mix.env()}.exs"
