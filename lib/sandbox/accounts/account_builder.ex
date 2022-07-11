defmodule Sandbox.Accounts.AccountBuilder do
  @max_count 4

  alias Sandbox.Utils.Generator

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
      institution: institution(id),
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

  defp institution(token) do
    seed_random(token)

    institution_name =
      Enum.random(["Chase", "Bank of America", "Wells Fargo", "Citibank", "Capital One"])

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
    |> :crypto.bytes_to_integer()
    |> rem(@max_count)
    |> Kernel.+(1)
  end

  defp seed_random(seed) do
    seed_int = :crypto.bytes_to_integer(seed)
    :rand.seed(:exsplus, {seed_int, seed_int, seed_int})
  end
end
