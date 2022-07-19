defmodule Sandbox.AccountBuilderTest do
  use ExUnit.Case

  alias Sandbox.Ledger.AccountBuilder

  @token1 "test_one"
  @token2 "test_two"
  @account1 %{token: @token1, account_id: "acc_2776d00ed47e1bdd82f24"}
  @base_url Application.compile_env!(:sandbox, :base_url)

  describe "list_accounts/1" do
    test "returns all accounts for given token" do
      {:ok, accounts} = AccountBuilder.list_accounts(@token1, @base_url)
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
      {:ok, accounts1} = AccountBuilder.list_accounts(@token1, @base_url)
      assert Enum.any?(accounts1)
      assert {:ok, accounts1} == AccountBuilder.list_accounts(@token1, @base_url)

      {:ok, accounts2} = AccountBuilder.list_accounts(@token2, @base_url)
      assert Enum.any?(accounts2)
      assert {:ok, accounts2} == AccountBuilder.list_accounts(@token2, @base_url)

      assert accounts1 != accounts2
    end

    test "returns differnt number of accounts" do
      assert 1 == @token1 |> AccountBuilder.list_accounts(@base_url) |> elem(1) |> Enum.count()
      assert 4 == @token2 |> AccountBuilder.list_accounts(@base_url) |> elem(1) |> Enum.count()
    end
  end

  describe "get_account/2" do
    test "returns account for given id and token" do
      {:ok, account} =
        AccountBuilder.get_account(@account1.token, @account1.account_id, @base_url)

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

    test "returns error for not matching token" do
      assert assert {:error, :not_found} ==
                      AccountBuilder.get_account("token_other", "acc_other", @base_url)
    end

    test "accounts from list_accounts/1 accessible by get_account/2 only with the same token" do
      {:ok, accounts1} = AccountBuilder.list_accounts(@token1, @base_url)
      {:ok, accounts2} = AccountBuilder.list_accounts(@token2, @base_url)

      Enum.each(accounts1, fn account ->
        assert {:ok, %{}} = AccountBuilder.get_account(@token1, account.id, @base_url)
        assert {:error, :not_found} == AccountBuilder.get_account(@token2, account.id, @base_url)
      end)

      Enum.each(accounts2, fn account ->
        assert {:error, :not_found} == AccountBuilder.get_account(@token1, account.id, @base_url)
        assert {:ok, %{}} = AccountBuilder.get_account(@token2, account.id, @base_url)
      end)
    end
  end
end
