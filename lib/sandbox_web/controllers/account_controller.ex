defmodule SandboxWeb.AccountController do
  use SandboxWeb, :controller

  alias Sandbox.LedgerBehaviour

  action_fallback SandboxWeb.FallbackController

  def index(conn, _params) do
    with {:ok, accounts} <-
           LedgerBehaviour.impl().list_accounts(conn.assigns.token, get_base_url()) do
      render(conn, "index.json", accounts: accounts)
    else
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, account} <-
           LedgerBehaviour.impl().get_account(conn.assigns.token, id, get_base_url()) do
      render(conn, "show.json", account: account)
    else
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  defp get_base_url do
    SandboxWeb.Endpoint.url()
  end
end
