defmodule Sandbox.AccountDetailsBuilderTest do
  use ExUnit.Case

  alias Sandbox.Ledger.AccountDetailsBuilder

  @token "test_one"
  @account_id "acc_2776d00ed47e1bdd82f24"
  @base_url Application.compile_env!(:sandbox, :base_url)

  describe "get_account_details/1" do
    test "returns account details for given account_id and token" do
      {:ok, account} =
        AccountDetailsBuilder.get_account_details(%{
          token: @token,
          account_id: @account_id,
          base_url: @base_url
        })

      assert %{
               account_id: _,
               account_number: _,
               links: %{
                 account: _,
                 self: _
               },
               routing_numbers: %{
                 ach: _
               }
             } = account
    end

    test "returns error for not matching token" do
      assert assert {:error, :not_found} ==
                      AccountDetailsBuilder.get_account_details(%{
                        token: "other_token",
                        account_id: @account_id,
                        base_url: @base_url
                      })
    end
  end
end
