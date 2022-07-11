defmodule Sandbox.Accounts.TransactionBuilder do
  alias Sandbox.Accounts.AccountBuilder
  alias Sandbox.Utils.Generator

  def list_transactions(token, account_id) do
    if AccountBuilder.get_account(token, account_id) do
      today = Date.utc_today()

      Enum.flat_map(0..89, fn day_index ->
        date = Date.add(today, -day_index)
        trx_count = Generator.generate_integer("trx_#{token}_#{date}", 5)

        Enum.map(1..trx_count, fn sub_day_index ->
          trx_id = Generator.generate_id("trx_#{token}_#{day_index}_#{sub_day_index}", "trx")
          build_transaction(trx_id, account_id)
        end)
      end)
    else
      []
    end
  end

  def get_transaction(token, account_id, trx_id) do
    token
    |> list_transactions(account_id)
    |> Enum.find(fn %{id: id} -> id == trx_id end)
  end

  defp build_transaction(trx_id, account_id) do
    %{
      account_id: account_id,
      amount: "-84.88",
      date: "2022-07-10",
      description: "Electronic Withdrawal",
      details: %{
        category: "service",
        counterparty: %{
          name: "BANK OF THE WEST",
          type: "organization"
        },
        processing_status: "complete"
      },
      id: trx_id,
      links: %{
        account: "https://api.teller.io/accounts/#{account_id}",
        self: "https://api.teller.io/accounts/#{account_id}/transactions/#{trx_id}"
      },
      running_balance: nil,
      status: "pending",
      type: "card_payment"
    }
  end
end
