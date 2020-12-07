defmodule AnalyticsEx.Metrics do
  use Supervisor

  @worker AnalyticsEx.Metrics.Worker
  @registry AnalyticsEx.Metrics.Registry
  @supervisor AnalyticsEx.Metrics.WorkerSupervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    children = [
      {Registry, keys: :unique, name: @registry},
      {DynamicSupervisor, name: @supervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

  def bump(path) when is_binary(path) do
    pid =
      case Registry.lookup(@registry, path) do
        [{pid, _}] ->
          pid

        [] ->
          case DynamicSupervisor.start_child(@supervisor, {@worker, path}) do
            {:ok, pid} -> pid
            {:error, {:already_started, pid}} -> pid
          end
      end

    send(pid, :bump)
  end

  def bump_with_uri(uri) when is_binary(uri) do
    uri
    |> URI.parse()
    |> Map.get(:path)
    |> case do
      nil ->
        {:error, :path_not_found}

      path ->
        bump(path)
        :ok
    end
  end
end
