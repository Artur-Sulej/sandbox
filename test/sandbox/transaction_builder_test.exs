defmodule Sandbox.TransactionBuilderTest do
  use ExUnit.Case

  alias Sandbox.Accounts.TransactionBuilder

  @token1 "test_one"
  @token2 "test_two"
  @account_id1 "acc_2776d00ed47e1bdd82f24"
  @account_id2 "acc_1a12637aded5310a22365"
  @today ~D[2022-07-15]

  describe "list_transactions/2" do
    test "returns all transactions for given account" do
      transactions1 = TransactionBuilder.list_transactions(@token1, @account_id1)
      transactions2 = TransactionBuilder.list_transactions(@token2, @account_id1)

      assert Enum.any?(transactions1)
      assert Enum.empty?(transactions2)

      Enum.each(transactions1, fn trx ->
        assert %{
                 account_id: @account_id1,
                 amount: "-84.88",
                 date: _,
                 description: "Electronic Withdrawal",
                 details: %{
                   category: "service",
                   counterparty: %{name: "BANK OF THE WEST", type: "organization"},
                   processing_status: "complete"
                 },
                 id: _,
                 links: %{
                   account: _,
                   self: _
                 },
                 running_balance: nil,
                 status: "pending",
                 type: "card_payment"
               } = trx
      end)
    end

    test "returns transactions for last 90 days" do
      transactions = TransactionBuilder.list_transactions(@token1, @account_id1)
      first_trx = List.first(transactions)
      last_trx = List.last(transactions)

      end_date = Date.utc_today()
      start_date = Date.add(end_date, -89)

      end_date_comparison = Date.compare(end_date, Date.from_iso8601!(first_trx.date))
      start_date_comparison = Date.compare(start_date, Date.from_iso8601!(last_trx.date))

      assert transactions == Enum.sort_by(transactions, & &1.date, &>=/2)
      assert :gt == end_date_comparison || :eq == end_date_comparison
      assert :lt == start_date_comparison || :eq == start_date_comparison
    end

    test "moving time window doesn't change transactions for same days" do
      from_date1 = ~D[2022-04-26]
      from_date2 = ~D[2022-07-14]

      transactions1 = TransactionBuilder.list_transactions(@token1, @account_id1, from_date1)
      transactions2 = TransactionBuilder.list_transactions(@token1, @account_id1, from_date2)
      helper_list = transactions1 -- transactions2
      trx_intersection = Enum.sort_by(transactions1 -- helper_list, & &1.date, &>=/2)

      first_trx = List.first(trx_intersection)
      last_trx = List.last(trx_intersection)

      assert {first_trx.date, last_trx.date} == {"2022-04-26", "2022-04-16"}
    end

    test "returns constant transactions and different for two accounts" do
      transactions1a = TransactionBuilder.list_transactions(@token1, @account_id1)
      transactions1b = TransactionBuilder.list_transactions(@token1, @account_id1)
      transactions2a = TransactionBuilder.list_transactions(@token2, @account_id2)
      transactions2b = TransactionBuilder.list_transactions(@token2, @account_id2)

      assert transactions1a == transactions1b
      assert transactions2a == transactions2b
      assert transactions2a != transactions1a
    end

    test "limiting transactions with count param" do
      count = 4
      trx_all = TransactionBuilder.list_transactions(@token1, @account_id1, @today)
      trx_with_count = TransactionBuilder.list_transactions(@token1, @account_id1, @today, count)

      assert count == Enum.count(trx_with_count)
      assert trx_with_count == Enum.take(trx_all, count)
    end

    test "paginating transactions with id and count" do
      count = 2
      trx_all = TransactionBuilder.list_transactions(@token1, @account_id1, @today)
      [_, %{id: from_id}, trx_1, trx_2 | _tail] = trx_all

      trx_with_count_from_id =
        TransactionBuilder.list_transactions(@token1, @account_id1, @today, count, from_id)

      assert count == Enum.count(trx_with_count_from_id)
      assert [^trx_1, ^trx_2] = trx_with_count_from_id
    end
  end

  describe "get_transaction/3" do
    test "returns transaction only for correct token and ids" do
      trx_id = "trx_7018e716c17bd1457eaa8"

      assert TransactionBuilder.get_transaction(@token1, @account_id1, trx_id, @today) ==
               build_transaction(trx_id, @account_id1, "2022-04-17")

      refute TransactionBuilder.get_transaction("other_token", @account_id1, trx_id, @today)
      refute TransactionBuilder.get_transaction(@token1, "other_account", trx_id, @today)
      refute TransactionBuilder.get_transaction(@token1, @account_id1, "other_trx")
    end

    test "listed transaction accessible via get_transaction/3" do
      transactions1 = TransactionBuilder.list_transactions(@token1, @account_id1, @today)
      transactions2 = TransactionBuilder.list_transactions(@token2, @account_id2, @today)

      assert Enum.any?(transactions1)
      assert Enum.any?(transactions2)

      Enum.each(transactions1, fn transaction ->
        assert TransactionBuilder.get_transaction(@token1, @account_id1, transaction.id, @today)
        refute TransactionBuilder.get_transaction(@token2, @account_id2, transaction.id, @today)
      end)

      Enum.each(transactions2, fn transaction ->
        refute TransactionBuilder.get_transaction(@token1, @account_id1, transaction.id, @today)
        assert TransactionBuilder.get_transaction(@token2, @account_id2, transaction.id, @today)
      end)
    end

    defp build_transaction(trx_id, account_id, date) do
      %{
        account_id: account_id,
        amount: "-84.88",
        date: date,
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
end
