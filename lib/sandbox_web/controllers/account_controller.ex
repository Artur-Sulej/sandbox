defmodule SandboxWeb.AccountController do
  use SandboxWeb, :controller

  alias Sandbox.Accounts

  action_fallback SandboxWeb.FallbackController

  def index(conn, _params) do
    accounts = Accounts.list_accounts(conn.assigns.token)
    render(conn, "index.json", accounts: accounts)
  end

  def show(conn, %{"id" => id}) do
    account = Accounts.get_account(conn.assigns.token, id)
    render(conn, "show.json", account: account)
  end
end
