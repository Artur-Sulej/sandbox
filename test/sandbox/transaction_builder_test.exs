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

    test "get_transaction/3 returns transaction only for correct token and ids" do
      token = "test_uno"
      account_id = "acc_79725939aa3d0c2b18a15"
      trx_id = "trx_1401dfc7893e4f5961b75"

      assert TransactionBuilder.get_transaction(token, account_id, trx_id)

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
      account_id1 = "acc_4d9d0a6d597639ae2a79d"
      account_id2 = "acc_a2a8b8911c5312b9ea9a6"

      transactions1 = TransactionBuilder.list_transactions(token1, account_id1)
      transactions2 = TransactionBuilder.list_transactions(token2, account_id2)

      Enum.each(transactions1, fn transaction ->
        assert TransactionBuilder.get_transaction(token1, account_id1, transaction.id)
        refute TransactionBuilder.get_transaction(token2, account_id2, transaction.id)
      end)

      Enum.each(transactions2, fn transaction ->
        refute TransactionBuilder.get_transaction(token1, account_id1, transaction.id)
        assert TransactionBuilder.get_transaction(token2, account_id2, transaction.id)
      end)
    end
  end
end
