defmodule Sandbox.Ledger.AccountBuilder do
  alias Sandbox.Utils.Generator
  alias Sandbox.Ledger.Labels.Institutions

  @max_count 4

  def list_accounts(token, base_url) do
    accounts = generate_accounts(token, base_url)
    {:ok, accounts}
  end

  def get_account(token, account_id, base_url) do
    account =
      token
      |> generate_accounts(base_url)
      |> Enum.find(fn %{id: id} -> id == account_id end)

    case account do
      nil -> {:error, :not_found}
      account -> {:ok, account}
    end
  end

  defp generate_accounts(token, base_url) do
    token
    |> get_accounts_count()
    |> (&(1..&1)).()
    |> Enum.map(&Generator.generate_id("acc_#{token}_#{&1}", "acc"))
    |> Enum.map(&build_account(&1, base_url))
  end

  defp build_account(id, base_url) do
    %{
      currency: "USD",
      enrollment_id: "enr_o3oveb8h0pukpk616a000",
      id: id,
      institution: get_institution(id),
      last_four: "5765",
      links: %{
        balances: "#{base_url}/accounts/#{id}/balances",
        self: "#{base_url}/accounts/#{id}",
        transactions: "#{base_url}/accounts/#{id}/transactions"
      },
      name: "Platinum Card",
      status: "open",
      subtype: "credit_card",
      type: "credit"
    }
  end

  defp get_institution(seed) do
    institution_name = Generator.random_item(Institutions.get_values(), seed)

    institution_id =
      institution_name
      |> String.replace(" ", "_")
      |> String.downcase()

    %{
      id: institution_id,
      name: institution_name
    }
  end

  defp get_accounts_count(token) do
    token
    |> Generator.generate_integer(@max_count - 1)
    |> Kernel.+(1)
  end
end
