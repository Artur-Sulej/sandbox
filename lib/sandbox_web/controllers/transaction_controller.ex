defmodule SandboxWeb.TransactionController do
  use SandboxWeb, :controller

  alias Sandbox.Accounts

  action_fallback SandboxWeb.FallbackController

  def index(conn, _params) do
    transactions = Accounts.list_transactions(conn.assigns.token, "")
    render(conn, "index.json", transactions: transactions)
  end

  def show(conn, %{"id" => id}) do
    transaction = Accounts.get_transaction(conn.assigns.token, "", "")
    render(conn, "show.json", transaction: transaction)
  end
end
