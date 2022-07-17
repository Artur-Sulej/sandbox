defmodule Sandbox.Accounts.TransactionBuilder do
  alias Sandbox.Accounts.AccountBuilder
  alias Sandbox.Utils.Generator

  @days_count 90
  @min_trx_per_day 0
  @max_trx_per_day 5

  def list_transactions(
        token,
        account_id,
        from_date \\ nil,
        transactions_count \\ nil,
        from_id \\ nil
      ) do
    if AccountBuilder.get_account(token, account_id) do
      from_date = from_date || Date.utc_today()

      token
      |> transactions_stream(account_id, from_date)
      |> drop_until_id(from_id)
      |> take(transactions_count)
    else
      []
    end
  end

  def get_transaction(token, account_id, trx_id, date \\ nil) do
    if AccountBuilder.get_account(token, account_id) do
      token
      |> transactions_stream(account_id, date)
      |> Stream.filter(&(&1.id == trx_id))
      |> Enum.take(1)
      |> List.first()
    else
      nil
    end
  end

  defp transactions_stream(token, account_id, from_date) do
    from_date
    |> Stream.iterate(&Date.add(&1, -1))
    |> Stream.take(@days_count)
    |> Stream.flat_map(&generate_transactions_for_date(&1, token, account_id))
  end

  defp generate_transactions_for_date(date, token, account_id) do
    trx_count = Generator.generate_integer("trx_#{token}_#{date}", @max_trx_per_day)

    Enum.map(@min_trx_per_day..trx_count, fn sub_day_index ->
      trx_id = Generator.generate_id("trx_#{token}_#{date}_#{sub_day_index}", "trx")
      build_transaction(trx_id, account_id, date)
    end)
  end

  defp take(stream, _count = nil) do
    Enum.to_list(stream)
  end

  defp take(stream, count) do
    Enum.take(stream, count)
  end

  defp drop_until_id(stream, _from_id = nil) do
    stream
  end

  defp drop_until_id(stream, from_id) do
    stream
    |> Stream.drop_while(&(&1.id != from_id))
    |> Stream.drop(1)
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
