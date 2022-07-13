defmodule Sandbox.TransactionBuilderTest do
  use ExUnit.Case

  alias Sandbox.Accounts.TransactionBuilder

  @token1 "test_one"
  @token2 "test_two"
  @account_id1 "acc_2776d00ed47e1bdd82f24"
  @account_id2 "acc_1a12637aded5310a22365"

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
                 date: "2022-07-10",
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
      sorted_trx = Enum.sort_by(transactions, & &1.date, &>=/2)
      first_trx = List.first(sorted_trx)
      last_trx = List.last(sorted_trx)

      end_date = Date.utc_today()
      start_date = Date.add(end_date, -89)

      end_date_comparison = Date.compare(end_date, Date.from_iso8601!(first_trx.date))
      start_date_comparison = Date.compare(start_date, Date.from_iso8601!(last_trx.date))

      assert :gt == end_date_comparison || :eq == end_date_comparison
      assert :lt == start_date_comparison || :eq == start_date_comparison
    end

    test "returns constant transactions and different for two accounts" do
      transactions1 = TransactionBuilder.list_transactions(@token1, @account_id1)
      transactions2 = TransactionBuilder.list_transactions(@token2, @account_id2)

      assert transactions2 != transactions1
    end
  end

  describe "get_transaction/3" do
    test "returns transaction only for correct token and ids" do
      trx_id = "trx_2f76a945be343d16960e4"

      assert TransactionBuilder.get_transaction(@token1, @account_id1, trx_id) ==
               build_transaction(trx_id, @account_id1)

      refute TransactionBuilder.get_transaction("other_token", @account_id1, trx_id)
      refute TransactionBuilder.get_transaction(@token1, "other_account", trx_id)
      refute TransactionBuilder.get_transaction(@token1, @account_id1, "other_trx")
    end

    test "listed transaction accessible via get_transaction/3" do
      transactions1 = TransactionBuilder.list_transactions(@token1, @account_id1)
      transactions2 = TransactionBuilder.list_transactions(@token2, @account_id2)

      assert Enum.any?(transactions1)
      assert Enum.any?(transactions2)

      Enum.each(transactions1, fn transaction ->
        assert TransactionBuilder.get_transaction(@token1, @account_id1, transaction.id)
        refute TransactionBuilder.get_transaction(@token2, @account_id2, transaction.id)
      end)

      Enum.each(transactions2, fn transaction ->
        refute TransactionBuilder.get_transaction(@token1, @account_id1, transaction.id)
        assert TransactionBuilder.get_transaction(@token2, @account_id2, transaction.id)
      end)
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
end
