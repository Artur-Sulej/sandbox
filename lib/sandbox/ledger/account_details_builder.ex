defmodule Sandbox.Ledger.AccountDetailsBuilder do
  @moduledoc false

  alias Sandbox.Ledger.AccountBuilder

  def get_account_details(opts) do
    if account_valid?(opts.token, opts.account_id, opts.base_url) do
      account_details = build_account_details(opts.account_id, opts.base_url)
      {:ok, account_details}
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

  defp build_account_details(account_id, base_url) do
    %{
      account_id: account_id,
      account_number: "506488969332",
      links: %{
        account: "#{base_url}/accounts/#{account_id}",
        self: "#{base_url}/accounts/#{account_id}/details"
      },
      routing_numbers: %{
        ach: "115394708"
      }
    }
  end
end
