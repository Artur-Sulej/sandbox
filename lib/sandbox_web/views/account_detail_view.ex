defmodule SandboxWeb.AccountDetailView do
  use SandboxWeb, :view
  alias SandboxWeb.AccountDetailView

  def render("show.json", %{account_detail: account_detail}) do
    render_one(account_detail, AccountDetailView, "account_detail.json")
  end

  def render("account_detail.json", %{account_detail: account_detail}) do
    account_detail
  end
end
