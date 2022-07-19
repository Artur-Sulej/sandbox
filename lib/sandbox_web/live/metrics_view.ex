defmodule SandboxWeb.MetricsView do
  use SandboxWeb, :live_view

  alias Phoenix.PubSub
  alias Sandbox.MetricsServer

  @topic MetricsServer.topic()

  def mount(_params, _session, socket) do
    PubSub.subscribe(Sandbox.PubSub, @topic)
    {:ok, assign(socket, metrics: MetricsServer.current())}
  end

  def handle_info({:update_metrics, metrics}, socket) do
    {:noreply, assign(socket, metrics: metrics)}
  end

  def render(assigns) do
    ~L"""
    <div>
      <h1>Number of requests per token</h1>
      <table>
        <tr>
          <th>Token</th>
          <th>Requests</th>
        </tr>
        <%= Enum.map(@metrics, fn {token, count} -> %>
          <tr>
            <td><%= token %></td>
            <td><%= count %></td>
          </tr>
        <% end) %>
      </table>
    </div>
    """
  end
end
