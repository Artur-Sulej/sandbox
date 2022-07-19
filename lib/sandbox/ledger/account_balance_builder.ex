defmodule Sandbox.Ledger.AccountBalanceBuilder do
  alias Sandbox.Ledger.AccountBuilder

  def get_account_balance(opts) do
    if account_valid?(opts.token, opts.account_id, opts.base_url) do
      account_balance = build_account_balance(opts.account_id, opts.base_url)
      {:ok, account_balance}
    else
      {:error, :not_found}
    end
  end

  defp account_valid?(token, account_id, base_url) do
    case AccountBuilder.get_account(token, account_id, base_url) do
      {:error, _} -> false
      _ -> true
    end
  end

  defp build_account_balance(account_id, base_url) do
    %{
      account_id: account_id,
      available: "33648.09",
      ledger: "33803.48",
      links: %{
        account: "#{base_url}/accounts/acc_nmfff743stmo5n80t4000",
        self: "#{base_url}/accounts/acc_nmfff743stmo5n80t4000/balances"
      }
    }
  end
end
