defmodule AnalyticsEx.Config do
  @doc """
  Retrieves the repo module from the config, or raises an exception.
  """
  def repo! do
    Application.get_env(:analytics_ex, :repo) || raise("No `:repo` configuration option found.")
  end

  def ensure_repo, do: repo!()
end
