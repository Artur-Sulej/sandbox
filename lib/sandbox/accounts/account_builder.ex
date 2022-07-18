defmodule Sandbox.Accounts.AccountBuilder do
  alias Sandbox.Utils.Generator
  alias Sandbox.Accounts.Labels.Institutions

  @max_count 4

  def list_accounts(token) do
    token
    |> get_accounts_count()
    |> (&(1..&1)).()
    |> Enum.map(&Generator.generate_id("acc_#{token}_#{&1}", "acc"))
    |> Enum.map(&build_account/1)
  end

  def get_account(token, account_id) do
    token
    |> list_accounts()
    |> Enum.find(fn %{id: id} -> id == account_id end)
  end

  defp build_account(id) do
    %{
      currency: "USD",
      enrollment_id: "enr_o3oveb8h0pukpk616a000",
      id: id,
      institution: get_institution(id),
      last_four: "5765",
      links: %{
        balances: "https://api.teller.io/accounts/#{id}/balances",
        self: "https://api.teller.io/accounts/#{id}",
        transactions: "https://api.teller.io/accounts/#{id}/transactions"
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
