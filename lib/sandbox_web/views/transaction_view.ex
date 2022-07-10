defmodule SandboxWeb.TransactionView do
  use SandboxWeb, :view
  alias SandboxWeb.TransactionView

  def render("index.json", %{transactions: transactions}) do
    render_many(transactions, TransactionView, "transaction.json")
  end

  def render("show.json", %{transaction: transaction}) do
    render_one(transaction, TransactionView, "transaction.json")
  end

  def render("transaction.json", %{transaction: transaction}) do
    transaction
  end
end
