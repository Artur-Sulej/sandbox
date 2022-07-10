defmodule Sandbox.AccountBuilderTest do
  use ExUnit.Case

  alias Sandbox.Accounts.AccountBuilder

  describe "accounts" do
    test "list_accounts/1 returns all accounts" do
      expected_account1 =
        build_account(%{
          id: "acc_a4140199141fc96b362f0",
          institution: %{id: "bank_of_america", name: "Bank of America"}
        })

      expected_account2 =
        build_account(%{
          id: "acc_97b9197aca031090df84f",
          institution: %{id: "wells_fargo", name: "Wells Fargo"}
        })

      assert [expected_account1, expected_account2] == AccountBuilder.list_accounts("token1")
    end

    test "list_accounts/1 returns differnt number of accounts" do
      accounts1 = AccountBuilder.list_accounts("token_one")
      accounts2 = AccountBuilder.list_accounts("token_two")

      assert 2 = Enum.count(accounts1)
      assert 4 = Enum.count(accounts2)
    end

    test "get_account/2 returns account for given id and token" do
      account = AccountBuilder.get_account("token1", "acc_a4140199141fc96b362f0")

      expected_account =
        build_account(%{
          institution: %{id: "bank_of_america", name: "Bank of America"},
          id: "acc_a4140199141fc96b362f0"
        })

      assert account == expected_account
    end

    test "get_account/2 returns nil for not matching token" do
      account = AccountBuilder.get_account("token_other", "acc_a4140199141fc96b362f0")

      refute account
    end

    test "accounts from list_accounts/1 accessible by get_account/2 only with the same token" do
      token1 = "test_uno"
      token2 = "test_duo"
      accounts1 = AccountBuilder.list_accounts(token1)
      accounts2 = AccountBuilder.list_accounts(token2)

      Enum.each(accounts1, fn account ->
        assert AccountBuilder.get_account(token1, account.id)
        refute AccountBuilder.get_account(token2, account.id)
      end)

      Enum.each(accounts2, fn account ->
        refute AccountBuilder.get_account(token1, account.id)
        assert AccountBuilder.get_account(token2, account.id)
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
