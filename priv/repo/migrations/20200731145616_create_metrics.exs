defmodule AnalyticsEx.Repo.Migrations.CreateMetrics do
  use Ecto.Migration

  def change do
    create table(:metrics, primary_key: false) do
      add :date, :date, primary_key: true
      add :path, :string, primary_key: true
      add :counter, :integer, default: 0
    end
  end
end
