defmodule Sandbox.Plug.Metrics do
  def init(options), do: options

  def call(conn, _opts) do
    Sandbox.MetricsServer.increment(conn.assigns.token)
    conn
  end
end
