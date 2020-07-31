# AnalyticsEx

A library trackiong how many visitors a [Phoenix](https://github.com/phoenixframework/phoenix)-based application receives per day without collecting any data from the user. It encapsulates the [Homemade Analytics](https://dashbit.co/blog/homemade-analytics-with-ecto-and-elixir) code of `José Valim` and simply counts the page-requests per path per day. The collected data is stored in a configurable [Ecto](https://github.com/elixir-ecto/ecto)-repository.

## Installation

### 1. Add the `analytics_ex` dependency
Add the following to your mix.exs and run mix deps.get:
```elixir
def deps do
  [
    {:analytics_ex, "~> 0.1.0"}
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
```

## Thanks

### José Valim
Special thanks to José Valim not only for creating Elixir, Ecto, and many more useful things, but also for writing the [Homemade analytics with Ecto and Elixir](https://dashbit.co/blog/homemade-analytics-with-ecto-and-elixir) blog post on the [Dashbit](https://dasbit.co) website.

### kipcole9
Thanks to [kip](https://elixirforum.com/u/kip/summary) for his [answer](https://elixirforum.com/t/how-to-run-migrations-that-are-in-a-library/26811/9?u=pjullrich) on ElixirForum and his [implementation](https://github.com/kipcole9/money_sql/blob/master/lib/mix/tasks/money_postgres_migration.ex) of how to generate an Ecto migration in the application which uses the library.