defmodule Sandbox.AccountBalanceBuilderTest do
  use ExUnit.Case

  alias Sandbox.Ledger.AccountBalanceBuilder

  @token "test_one"
  @account_id "acc_2776d00ed47e1bdd82f24"
  @base_url Application.compile_env!(:sandbox, :base_url)

  describe "get_account_balance/1" do
    test "returns account balance for given account_id and token" do
      {:ok, account} =
        AccountBalanceBuilder.get_account_balance(%{
          token: @token,
          account_id: @account_id,
          base_url: @base_url
        })

      assert %{
               account_id: _,
               available: _,
               ledger: _,
               links: %{
                 account: _,
                 self: _
               }
             } = account
    end

    test "returns error for not matching token" do
      assert assert {:error, :not_found} ==
                      AccountBalanceBuilder.get_account_balance(%{
                        token: "other_token",
                        account_id: @account_id,
                        base_url: @base_url
                      })
    end
  end
end
