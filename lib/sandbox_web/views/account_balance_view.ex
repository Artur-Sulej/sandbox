defmodule SandboxWeb.AccountBalanceView do
  use SandboxWeb, :view
  alias SandboxWeb.AccountBalanceView

  def render("show.json", %{account_balance: account_balance}) do
    render_one(account_balance, AccountBalanceView, "account_balance.json")
  end

  def render("account_balance.json", %{account_balance: account_balance}) do
    account_balance
  end
end
