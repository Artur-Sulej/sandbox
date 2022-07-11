defmodule Sandbox.TransactionBuilderTest do
  use ExUnit.Case

  alias Sandbox.Accounts.TransactionBuilder

  describe "transactions" do
    test "list_transactions/2 returns all transactions for given account" do
      token = "test_uno"
      account_id = "acc_79725939aa3d0c2b18a15"
      transactions = TransactionBuilder.list_transactions(token, account_id)
      transactions2 = TransactionBuilder.list_transactions(token, "other_account")

      assert Enum.any?(transactions)
      assert Enum.empty?(transactions2)

      Enum.each(transactions, fn trx ->
        assert trx.account_id == account_id
      end)
    end

    test "list_transactions/2 returns transactions for last 90 days" do
      token = "test_uno"
      account_id = "acc_79725939aa3d0c2b18a15"
      transactions = TransactionBuilder.list_transactions(token, account_id)

      end_date = Date.utc_today()
      start_date = Date.add(end_date, -89)
      sorted_trx = Enum.sort_by(transactions, & &1.date, &>=/2)
      first_trx = List.first(sorted_trx)
      last_trx = List.last(sorted_trx)
      end_date_comparison = Date.compare(end_date, Date.from_iso8601!(first_trx.date))
      start_date_comparison = Date.compare(start_date, Date.from_iso8601!(last_trx.date))

      assert :gt == end_date_comparison || :eq == end_date_comparison
      assert :lt == start_date_comparison || :eq == start_date_comparison
    end

    test "list_transactions/2 returns different results for accounts" do
      token = "test_uno"
      account_id = "acc_79725939aa3d0c2b18a15"
      transactions = TransactionBuilder.list_transactions(token, account_id)

      token2 = "test_duo"
      account_id2 = "acc_72607085fef10d84883e9"
      transactions2 = TransactionBuilder.list_transactions(token2, account_id2)

      assert Enum.count(transactions2) != Enum.count(transactions)
    end

    test "get_transaction/3 returns transaction only for correct token and ids" do
      token = "test_uno"
      account_id = "acc_79725939aa3d0c2b18a15"
      trx_id = "trx_1401dfc7893e4f5961b75"

      assert TransactionBuilder.get_transaction(token, account_id, trx_id) ==
               build_transaction(trx_id, account_id)

      refute TransactionBuilder.get_transaction(
               "other_token",
               account_id,
               "txn_o3q8oei9er0iq9k7qe000"
             )

      refute TransactionBuilder.get_transaction(
               token,
               "other_account",
               "txn_o3q8oei9er0iq9k7qe000"
             )

      refute TransactionBuilder.get_transaction(token, account_id, "other_trx")
    end

    test "listed transaction accessible via get_transaction/3" do
      token1 = "test_uno"
      token2 = "test_duo"
      account_id1 = "acc_79725939aa3d0c2b18a15"
      account_id2 = "acc_72607085fef10d84883e9"
      transactions1 = TransactionBuilder.list_transactions(token1, account_id1)
      transactions2 = TransactionBuilder.list_transactions(token2, account_id2)

      assert Enum.any?(transactions1)
      assert Enum.any?(transactions2)

      Enum.each(transactions1, fn transaction ->
        assert TransactionBuilder.get_transaction(token1, account_id1, transaction.id)
        refute TransactionBuilder.get_transaction(token2, account_id2, transaction.id)
      end)

      Enum.each(transactions2, fn transaction ->
        refute TransactionBuilder.get_transaction(token1, account_id1, transaction.id)
        assert TransactionBuilder.get_transaction(token2, account_id2, transaction.id)
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
