defmodule Sandbox.AccountsTest do
  use ExUnit.Case

  alias Sandbox.Accounts

  describe "accounts" do
    test "list_accounts/0 returns all accounts" do
      assert Accounts.list_accounts() == []
    end

    test "get_account/1 returns the account with given id" do
      assert Accounts.get_account(123) == nil
    end
  end
end
