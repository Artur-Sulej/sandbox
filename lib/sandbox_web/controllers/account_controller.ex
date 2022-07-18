defmodule SandboxWeb.AccountController do
  use SandboxWeb, :controller

  alias Sandbox.Accounts

  action_fallback SandboxWeb.FallbackController

  def index(conn, _params) do
    base_url = SandboxWeb.Endpoint.url()
    accounts = Accounts.list_accounts(conn.assigns.token, base_url)
    render(conn, "index.json", accounts: accounts)
  end

  def show(conn, %{"id" => id}) do
    base_url = SandboxWeb.Endpoint.url()
    account = Accounts.get_account(conn.assigns.token, id, base_url)
    render(conn, "show.json", account: account)
  end
end
