# AnalyticsEx

## Heads up: This library is no longer actively maintained.
> I built this library before [Plausible.io](https://plausible.io) became a thing and I switched to that wonderful service by now. You can still use this library and report issues and I'll happily fix them. However, please don't expect this library to work forever or have features added to it.

A library tracking how many visitors a [Phoenix](https://github.com/phoenixframework/phoenix)-based application receives per day without collecting any data from the user. It encapsulates the [Homemade Analytics](https://dashbit.co/blog/homemade-analytics-with-ecto-and-elixir) code of `José Valim` and simply counts the page-requests per path per day. The collected data is stored in a configurable [Ecto](https://github.com/elixir-ecto/ecto)-repository.

## Installation

### 1. Add the `analytics_ex` dependency
Add the following to your mix.exs and run mix deps.get:
```elixir
def deps do
  [
    {:analytics_ex, "~> 0.2.1"}
  ]
end
```

### 2. Generate and run the Ecto Migration
In order to create the `metrics` table, please run the following commands:

```elixir
mix analytics.gen.migration
mix ecto.migrate
```

This will generate an `Ecto.Migration` which creates the `metrics` table into which we store the analytics data.

### 3. Configure which `Repo` to use
Tell the library which `Repo` to use for storing the analytics data.
```elixir
# In config.exs

config :analytics_ex, repo: MyApp.Repo
```

### 4. Add the `Plug` to your `router.ex`
In your `router.ex`, add the `AnalyticsEx.Plugs.CountRequestsPerPath`-Plug to any pipeline which is used by the routes which you want to track.

```elixir
  pipeline :browser do
    ...
    plug(AnalyticsEx.Plugs.CountRequestsPerPath)
  end
```****

### (Optional) Bump the metric manually in LiveViews
The `CountRequestsPerPath`-Plug will not pick up requests if the [push_patch/2](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html?#push_patch/2) function is used since LiveView updates the url in the address bar without a full page reload, that is without calling the `CountRequestsPerPath`-Plug again. If you want to track these requests as well, you have to manually bump the path metric in the [handle_params/3](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html?#c:handle_params/3) callback:

```elixir
def handle_params(params, uri, socket) do
  AnalyticsEx.Metrics.bump_with_uri(uri)

  # Do other stuff here
end
```

### (Optional) Add Analytics to LiveDashboard
You can add an overview of your analytics to your [Phoenix LiveDashboard](https://github.com/phoenixframework/phoenix_live_dashboard) by adding the following code to the `live_dashboard` route in your `router.ex`:

```elixir
    live_dashboard "/dashboard",
      additional_pages: [
        {:analytics, AnalyticsEx.LiveDashboard.AnalyticsPage}
      ]
```

Afterwards, you will have `daily`, `weekly`, and `monthly` summaries of your counted requests in the `Analytics` tab of your LiveDashboard.

If you want to exclude paths from the analytics in the dashboard, simply add them to `router.ex`:

```elixir
    live_dashboard "/dashboard",
      additional_pages: [
        {:analytics, {AnalyticsEx.LiveDashboard.AnalyticsPage, ignore: ["/this-route", "/and-that-route-including-subpaths"]}
      ]
```

You will then not see any paths which match your ignore-rules in the `Analytics` overview.

## Thanks

### José Valim
Special thanks to José Valim not only for creating Elixir, Ecto, and many more useful things, but also for writing the [Homemade analytics with Ecto and Elixir](https://dashbit.co/blog/homemade-analytics-with-ecto-and-elixir) blog post on the [Dashbit](https://dasbit.co) website.

### kipcole9
Thanks to [kip](https://elixirforum.com/u/kip/summary) for his [answer](https://elixirforum.com/t/how-to-run-migrations-that-are-in-a-library/26811/9?u=pjullrich) on ElixirForum and his [implementation](https://github.com/kipcole9/money_sql/blob/master/lib/mix/tasks/money_postgres_migration.ex) of how to generate an Ecto migration in the application which uses the library.
