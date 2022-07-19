defmodule Sandbox.Plug.Metrics do
  @moduledoc """
  This plug updated live metrics for every request that passes through it.
  """

  def init(options), do: options

  def call(conn, _opts) do
    Sandbox.MetricsServer.increment(conn.assigns.token)
    conn
  end
end
