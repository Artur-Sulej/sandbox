defmodule Sandbox.AccountBuilderTest do
  use ExUnit.Case

  alias Sandbox.Accounts.AccountBuilder

  @token1 "test_one"
  @token2 "test_two"
  @account1 %{token: @token1, account_id: "acc_2776d00ed47e1bdd82f24"}

  describe "list_accounts/1" do
    test "returns all accounts for given token" do
      accounts = AccountBuilder.list_accounts(@token1)
      assert Enum.any?(accounts)

      Enum.each(accounts, fn account ->
        assert %{
                 currency: "USD",
                 enrollment_id: "enr_o3oveb8h0pukpk616a000",
                 id: "acc_" <> _,
                 institution: %{id: _, name: _},
                 last_four: "5765",
                 links: %{
                   balances: _,
                   self: _,
                   transactions: _
                 },
                 name: "Platinum Card",
                 status: "open",
                 subtype: "credit_card",
                 type: "credit"
               } = account
      end)
    end

    test "returns constant accounts and different for two tokens" do
      accounts1 = AccountBuilder.list_accounts(@token1)
      assert Enum.any?(accounts1)
      assert accounts1 == AccountBuilder.list_accounts(@token1)

      accounts2 = AccountBuilder.list_accounts(@token2)
      assert Enum.any?(accounts2)
      assert accounts2 == AccountBuilder.list_accounts(@token2)

      assert accounts1 != accounts2
    end

    test "returns differnt number of accounts" do
      assert 2 == @token1 |> AccountBuilder.list_accounts() |> Enum.count()
      assert 4 == @token2 |> AccountBuilder.list_accounts() |> Enum.count()
    end
  end

  describe "get_account/2" do
    test "returns account for given id and token" do
      account = AccountBuilder.get_account(@account1.token, @account1.account_id)

      assert %{
               currency: "USD",
               enrollment_id: "enr_o3oveb8h0pukpk616a000",
               id: "acc_" <> _,
               institution: %{id: _, name: _},
               last_four: "5765",
               links: %{
                 balances: _,
                 self: _,
                 transactions: _
               },
               name: "Platinum Card",
               status: "open",
               subtype: "credit_card",
               type: "credit"
             } = account
    end

    test "returns nil for not matching token" do
      assert is_nil(AccountBuilder.get_account("token_other", "acc_other"))
    end

    test "accounts from list_accounts/1 accessible by get_account/2 only with the same token" do
      accounts1 = AccountBuilder.list_accounts(@token1)
      accounts2 = AccountBuilder.list_accounts(@token2)

      Enum.each(accounts1, fn account ->
        assert AccountBuilder.get_account(@token1, account.id)
        refute AccountBuilder.get_account(@token2, account.id)
      end)

      Enum.each(accounts2, fn account ->
        refute AccountBuilder.get_account(@token1, account.id)
        assert AccountBuilder.get_account(@token2, account.id)
      end)
    end
  end
end
