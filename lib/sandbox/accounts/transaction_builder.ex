defmodule Sandbox.Accounts.TransactionBuilder do
  alias Sandbox.Accounts.AccountBuilder
  alias Sandbox.Utils.Generator

  @days_count 90
  @max_trx_per_day 5
  @opening_date ~D[2022-04-15]
  @max_amount_in_subunits 10000

  def list_transactions(
        token,
        account_id,
        from_date \\ nil,
        transactions_count \\ nil,
        from_id \\ nil
      ) do
    if AccountBuilder.get_account(token, account_id) do
      from_date = from_date || Date.utc_today()

      account_id
      |> transactions_stream(from_date)
      |> drop_until_id(from_id)
      |> take(transactions_count)
    else
      []
    end
  end

  def get_transaction(token, account_id, trx_id, date \\ nil) do
    if AccountBuilder.get_account(token, account_id) do
      account_id
      |> transactions_stream(date)
      |> Stream.filter(&(&1.id == trx_id))
      |> Enum.take(1)
      |> List.first()
    else
      nil
    end
  end

  defp transactions_stream(account_id, from_date) do
    days_since_opening = Date.diff(from_date, @opening_date)
    earliest_date = Date.add(from_date, -(@days_count - 1))

    from_date
    |> Stream.iterate(&Date.add(&1, -1))
    |> Stream.take(days_since_opening)
    |> Stream.flat_map(&generate_trx_data_for_date(&1, account_id))
    |> Stream.filter(fn %{date: date} -> Date.compare(earliest_date, date) in [:lt, :eq] end)
    |> Stream.map(&build_transaction(&1, account_id))
  end

  defp generate_trx_data_for_date(date, account_id) do
    trx_count = Generator.generate_integer("trx_#{account_id}_#{date}", @max_trx_per_day)

    case trx_count do
      0 ->
        []

      trx_count ->
        Enum.map(1..trx_count, fn sub_day_index ->
          seed = "trx_#{account_id}_#{date}_#{sub_day_index}"
          trx_id = Generator.generate_id(seed, "trx")
          amount = -1 * Generator.generate_integer(seed, @max_amount_in_subunits) / 100
          %{id: trx_id, date: date, amount: amount}
        end)
    end
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

  defp build_transaction(%{id: trx_id, date: date, amount: amount}, account_id) do
    %{
      account_id: account_id,
      amount: :erlang.float_to_binary(amount, decimals: 2),
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
