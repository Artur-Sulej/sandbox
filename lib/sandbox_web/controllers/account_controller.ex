defmodule SandboxWeb.AccountController do
  use SandboxWeb, :controller

  alias Sandbox.LedgerBehaviour

  action_fallback SandboxWeb.FallbackController

  def index(conn, _params) do
    result = LedgerBehaviour.impl().list_accounts(conn.assigns.token, get_base_url())

    case result do
      {:ok, accounts} -> render(conn, "index.json", accounts: accounts)
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  def show(conn, %{"id" => id}) do
    result = LedgerBehaviour.impl().get_account(conn.assigns.token, id, get_base_url())

    case result do
      {:ok, account} -> render(conn, "show.json", account: account)
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  defp get_base_url do
    SandboxWeb.Endpoint.url()
  end
end
