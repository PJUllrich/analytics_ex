defmodule AnalyticsEx.LiveDashboard.AnalyticsPage do
  use Phoenix.LiveDashboard.PageBuilder, refresher?: false

  alias Phoenix.LiveDashboard.ChartComponent
  alias AnalyticsEx.LiveDashboard.AnalyticsPage.Queries

  @menu_text "Analytics"

  @impl true
  def mount(params, session, socket) do
    ignored_paths = Keyword.get(session, :ignore, [])
    search_term = Map.get(params, "search")

    metrics = [
      %Telemetry.Metrics.Summary{
        name: ["daily", "requests"],
        tags: ["per path"],
        description: "Requests per path and day",
        unit: :unit
      },
      %Telemetry.Metrics.Summary{
        name: ["weekly", "requests"],
        tags: ["per path"],
        description: "Requests per path and week",
        unit: :unit
      },
      %Telemetry.Metrics.Summary{
        name: ["monthly", "requests"],
        tags: ["per path"],
        description: "Requests per path and month",
        unit: :unit
      }
    ]

    display_config = for _ <- 1..length(metrics), do: true

    if connected?(socket) do
      for metric <- metrics do
        send_history_to_metric(metric, ignored_paths, search_term)
      end
    end

    {
      :ok,
      assign(socket,
        metrics: metrics,
        search_term: search_term,
        ignored_paths: ignored_paths,
        display_config: display_config
      )
    }
  end

  @impl true
  def menu_link(_, %{dashboard_running?: false}) do
    :skip
  end

  @impl true
  def menu_link(%{"metrics" => nil}, _) do
    {:disabled, @menu_text, "https://hexdocs.pm/analytics_ex/live_dashboard_page.html"}
  end

  @impl true
  def menu_link(_, _) do
    {:ok, @menu_text}
  end

  @impl true
  def render_page(assigns) do
    items = [
      {:paths, name: "Requests", render: render_metrics(assigns)}
    ]

    nav_bar(items: items)
  end

  @impl true
  def handle_event(
        "toggle_metric",
        %{"metric-pos" => position},
        %{
          assigns: %{
            display_config: display_config,
            ignored_paths: ignored_paths,
            search_term: search_term
          }
        } = socket
      ) do
    position = String.to_integer(position)
    new_value = !Enum.at(display_config, position)

    if new_value do
      send_history_to_metric(
        Enum.at(socket.assigns.metrics, position),
        ignored_paths,
        search_term
      )
    end

    display_config =
      display_config
      |> Enum.with_index()
      |> Enum.map(fn {value, idx} -> if idx == position, do: new_value, else: value end)

    {:noreply, assign(socket, :display_config, display_config)}
  end

  defp metric_name(%{name: [name | _]}), do: name

  defp metric_id(metric) do
    "analytics-requests-#{metric_name(metric)}"
  end

  def render_metrics(assigns) do
    fn ->
      ~L"""
        <div class="analytics">
          <div class="row">
            <div class="col">
              <div class="btn-group-toggle">
                <%= for {metric, idx} <- Enum.with_index(@metrics) do %>
                <button phx-click="toggle_metric" phx-value-metric-pos=<%= idx %> class="btn btn-light btn-sm <%= if Enum.at(@display_config, idx), do: "active" %>"><%= metric_name(metric) %></button>
                <% end %>
              </div>
            </div>
            <div class="col d-flex justify-content-end">
              <form class="form-inline">
                <div class="form-row align-items-center">
                  <div class="col-auto">
                    <input type="search" name="search" class="form-control form-control-sm" value="<%= @search_term %>" placeholder="Search" phx-debounce="300">
                  </div>
                </div>
              </form>
            </div>
          </div>
          <div class="row mt-4">
            <%= for {metric, idx} <- Enum.with_index(@metrics) do %>
              <%= if Enum.at(@display_config, idx) do %>
                <%= live_component @socket, ChartComponent, id: metric_id(metric), metric: metric %>
              <% end %>
            <% end %>
          </div>
        </div>
      """
    end
  end

  defp send_history_to_metric(metric, ignored_paths, search) do
    metric
    |> Queries.data_for_metric(ignored_paths, search)
    |> Enum.each(fn data_point ->
      send_update(ChartComponent,
        id: metric_id(metric),
        data: [data_point]
      )
    end)
  end
end
