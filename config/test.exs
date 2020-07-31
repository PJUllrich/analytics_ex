import Config

config :analytics_ex, AnalyticsEx.Repo,
  database: "analytics_ex_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
