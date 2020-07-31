defmodule AnalyticsEx.Metrics.Worker do
  use GenServer, restart: :temporary
  import Ecto.Query

  @registry AnalyticsEx.Metrics.Registry

  def start_link(path) do
    GenServer.start_link(__MODULE__, path, name: {:via, Registry, {@registry, path}})
  end

  @impl true
  def init(path) do
    Process.flag(:trap_exit, true)
    {:ok, {path, _counter = 0}}
  end

  @impl true
  def handle_info(:bump, {path, 0}) do
    schedule_upsert()
    {:noreply, {path, 1}}
  end

  @impl true
  def handle_info(:bump, {path, counter}) do
    {:noreply, {path, counter + 1}}
  end

  @impl true
  def handle_info(:upsert, {path, counter}) do
    upsert!(path, counter)
    {:noreply, {path, 0}}
  end

  defp schedule_upsert() do
    Process.send_after(self(), :upsert, Enum.random(10..20) * 1_000)
  end

  defp upsert!(path, counter) do
    date = Date.utc_today()
    query = from(m in AnalyticsEx.Metrics.Metric, update: [inc: [counter: ^counter]])

    AnalyticsEx.Config.repo!().insert!(
      %AnalyticsEx.Metrics.Metric{date: date, path: path, counter: counter},
      on_conflict: query,
      conflict_target: [:date, :path]
    )
  end

  @impl true
  def terminate(_, {_path, 0}), do: :ok
  def terminate(_, {path, counter}), do: upsert!(path, counter)
end
