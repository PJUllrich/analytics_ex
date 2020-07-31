defmodule AnalyticsEx.Repo do
  use Ecto.Repo,
    otp_app: :analytics_ex,
    adapter: Ecto.Adapters.Postgres
end
