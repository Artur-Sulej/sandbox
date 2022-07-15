defmodule Sandbox.Accounts.TransactionBuilder do
  alias Sandbox.Accounts.AccountBuilder
  alias Sandbox.Utils.Generator

  @days_count 90
  @min_trx_per_day 0
  @max_trx_per_day 5

  def list_transactions(token, account_id, from_date \\ nil) do
    if AccountBuilder.get_account(token, account_id) do
      from_date = from_date || Date.utc_today()
      transactions = generate_transactions(token, account_id, from_date)
      transactions
    else
      []
    end
  end

  def get_transaction(token, account_id, trx_id, date \\ nil) do
    token
    |> list_transactions(account_id, date)
    |> Enum.find(fn %{id: id} -> id == trx_id end)
  end

  defp generate_transactions(token, account_id, from_date) do
    Enum.flat_map(0..(@days_count - 1), fn day_index ->
      date = Date.add(from_date, -day_index)
      generate_transactions_for_date(date, token, account_id)
    end)
  end

  defp generate_transactions_for_date(date, token, account_id) do
    trx_count = Generator.generate_integer("trx_#{token}_#{date}", @max_trx_per_day)

    Enum.map(@min_trx_per_day..trx_count, fn sub_day_index ->
      trx_id = Generator.generate_id("trx_#{token}_#{date}_#{sub_day_index}", "trx")
      build_transaction(trx_id, account_id, date)
    end)
  end

  defp build_transaction(trx_id, account_id, date) do
    %{
      account_id: account_id,
      amount: "-84.88",
      date: Date.to_string(date),
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
