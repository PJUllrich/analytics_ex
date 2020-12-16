defmodule AnalyticsEx.LiveDashboard.AnalyticsPage.Queries do
  import Ecto.Query

  def repo do
    Application.get_env(:analytics_ex, :repo)
  end

  def data_for_metric(metric, ignored_paths, path_search_term \\ nil)

  def data_for_metric(%{name: ["weekly" | _]}, ignored_paths, path_search_term) do
    from(
      m in "metrics",
      group_by: [fragment("date_trunc('week', ?)", m.date), m.path],
      order_by: [fragment("date_trunc('week', ?)", m.date), m.path],
      select: {
        m.path,
        sum(m.counter),
        fragment("extract(epoch from date_trunc('week', ?))::integer", m.date)
      }
    )
    |> filter(ignored_paths)
    |> search(path_search_term)
    |> get_and_shift_by(:week)
  end

  def data_for_metric(%{name: ["monthly" | _]}, ignored_paths, path_search_term) do
    from(
      m in "metrics",
      group_by: [fragment("date_trunc('month', ?)", m.date), m.path],
      order_by: [fragment("date_trunc('month', ?)", m.date), m.path],
      select: {
        m.path,
        sum(m.counter),
        fragment("extract(epoch from date_trunc('month', ?))::integer", m.date)
      }
    )
    |> filter(ignored_paths)
    |> search(path_search_term)
    |> get_and_shift_by(:month)
  end

  def data_for_metric(_metric, ignored_paths, path_search_term) do
    from(
      m in "metrics",
      order_by: [m.date, m.path],
      select: {m.path, m.counter, fragment("extract(epoch from ?)::integer", m.date)}
    )
    |> filter(ignored_paths)
    |> search(path_search_term)
    |> get_and_shift_by(:none)
  end

  defp filter(query, []), do: query

  defp filter(query, paths) do
    filter_term = Enum.join(paths, "|")
    where(query, [m], fragment(" ? !~* ?", m.path, ^filter_term))
  end

  defp search(query, nil), do: query

  defp search(query, search_term) do
    search_term = sanitize_sql_like(search_term)
    where(query, [m], ilike(m.path, ^search_term))
  end

  defp get_and_shift_by(query, shift_by) do
    repo().all(query) |> Enum.map(&convert_date(&1, shift_by))
  end

  defp convert_date({path, counter, date}, shift_by) do
    date =
      case shift_by do
        :month ->
          # Shift the data point for a month to the end of that month
          date + 30 * 24 * 60 * 60

        :week ->
          # Shift the data point for a week to the end of that week
          date + 7 * 24 * 60 * 60

        :none ->
          date
      end

    # Convert the epoch date from seconds to microseconds
    # which is the timestamp that the ChartComponent expects
    {path, counter, date * 1_000_000}
  end

  defp sanitize_sql_like(string) do
    String.replace(string, ~r/[("_"|"%"|"\\")]/, "")
  end
end
