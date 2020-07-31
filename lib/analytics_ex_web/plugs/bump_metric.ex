defmodule AnalyticsEx.Plugs.CountRequestsPerPath do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    register_before_send(conn, fn conn ->
      if conn.status == 200 do
        path = "/" <> Enum.join(conn.path_info, "/")
        AnalyticsEx.Metrics.bump(path)
      end

      conn
    end)
  end
end
