defmodule Sandbox.AccountsTest do
  use ExUnit.Case

  alias Sandbox.Accounts

  describe "accounts" do
    test "list_accounts/1 returns all accounts" do
      expected_account1 =
        build_account(%{
          id: "acc_33dbb45e693db9af2a24b",
          institution: %{id: "capital_one", name: "Capital One"}
        })

      expected_account2 =
        build_account(%{
          id: "acc_9e5c4bb9cd00aa12bb96d",
          institution: %{id: "citibank", name: "Citibank"}
        })

      assert [expected_account1, expected_account2] == Accounts.list_accounts("token1")
    end

    test "list_accounts/1 returns differnt number of accounts" do
      accounts1 = Accounts.list_accounts("token_one")
      accounts2 = Accounts.list_accounts("token_two")

      assert 2 = Enum.count(accounts1)
      assert 4 = Enum.count(accounts2)
    end

    test "get_account/2 returns account for given id and token" do
      account = Accounts.get_account("token1", "acc_33dbb45e693db9af2a24b")

      expected_account =
        build_account(%{
          institution: %{id: "capital_one", name: "Capital One"},
          id: "acc_33dbb45e693db9af2a24b"
        })

      assert account == expected_account
    end

    test "get_account/2 returns nil for not matching token" do
      account = Accounts.get_account("token_other", "acc_33dbb45e693db9af2a24b")

      refute account
    end

    test "accounts from list_accounts/1 accessible by get_account/2 only with the same token" do
      token1 = "test_uno"
      token2 = "test_duo"
      accounts1 = Accounts.list_accounts(token1)
      accounts2 = Accounts.list_accounts(token2)

      Enum.each(accounts1, fn account ->
        assert Accounts.get_account(token1, account.id)
        refute Accounts.get_account(token2, account.id)
      end)

      Enum.each(accounts2, fn account ->
        refute Accounts.get_account(token1, account.id)
        assert Accounts.get_account(token2, account.id)
      end)
    end

    test "list_transactions/2 returns all transactions for given account" do
      token = "test_uno"
      account_id = "acc_4d9d0a6d597639ae2a79d"
      transactions = Accounts.list_transactions(token, account_id)
      transactions2 = Accounts.list_transactions(token, "other_account")

      assert Enum.any?(transactions)
      assert Enum.empty?(transactions2)

      Enum.each(transactions, fn trx ->
        assert trx.account_id == account_id
      end)
    end

    test "get_transaction/3 returns transaction only for correct token and ids" do
      token = "test_uno"
      account_id = "acc_4d9d0a6d597639ae2a79d"
      trx_id = "trx_1401dfc7893e4f5961b75"

      assert Accounts.get_transaction(token, account_id, trx_id)
      refute Accounts.get_transaction("other_token", account_id, "txn_o3q8oei9er0iq9k7qe000")
      refute Accounts.get_transaction(token, "other_account", "txn_o3q8oei9er0iq9k7qe000")
      refute Accounts.get_transaction(token, account_id, "other_trx")
    end

    test "listed transaction accessible via get_transaction/3" do
      token1 = "test_uno"
      token2 = "test_duo"
      account_id1 = "acc_4d9d0a6d597639ae2a79d"
      account_id2 = "acc_a2a8b8911c5312b9ea9a6"

      transactions1 = Accounts.list_transactions(token1, account_id1)
      transactions2 = Accounts.list_transactions(token2, account_id2)

      Enum.each(transactions1, fn transaction ->
        assert Accounts.get_transaction(token1, account_id1, transaction.id)
        refute Accounts.get_transaction(token2, account_id2, transaction.id)
      end)

      Enum.each(transactions2, fn transaction ->
        refute Accounts.get_transaction(token1, account_id1, transaction.id)
        assert Accounts.get_transaction(token2, account_id2, transaction.id)
      end)
    end

    defp build_account(opts) do
      %{
        currency: "USD",
        enrollment_id: "enr_o3oveb8h0pukpk616a000",
        id: opts.id,
        institution: opts.institution,
        last_four: "5765",
        links: %{
          balances: "https://api.teller.io/accounts/#{opts.id}/balances",
          self: "https://api.teller.io/accounts/#{opts.id}",
          transactions: "https://api.teller.io/accounts/#{opts.id}/transactions"
        },
        name: "Platinum Card",
        status: "open",
        subtype: "credit_card",
        type: "credit"
      }
    end
  end
end
