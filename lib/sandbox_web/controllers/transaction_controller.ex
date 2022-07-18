defmodule SandboxWeb.TransactionController do
  use SandboxWeb, :controller

  alias Sandbox.Accounts

  action_fallback SandboxWeb.FallbackController

  def index(conn, %{"account_id" => account_id}) do
    transactions =
      Accounts.list_transactions(%{
        token: conn.assigns.token,
        account_id: account_id,
        base_url: SandboxWeb.Endpoint.url()
      })

    render(conn, "index.json", transactions: transactions)
  end

  def show(conn, %{"account_id" => account_id, "id" => id}) do
    transaction =
      Accounts.get_transaction(%{
        token: conn.assigns.token,
        account_id: account_id,
        id: id,
        base_url: SandboxWeb.Endpoint.url()
      })

    render(conn, "show.json", transaction: transaction)
  end
end
