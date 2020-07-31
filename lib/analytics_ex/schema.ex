defmodule AnalyticsEx.Metrics.Metric do
  use Ecto.Schema

  @primary_key false
  schema "metrics" do
    field(:date, :date, primary_key: true)
    field(:path, :string, primary_key: true)
    field(:counter, :integer, default: 0)
  end
end
