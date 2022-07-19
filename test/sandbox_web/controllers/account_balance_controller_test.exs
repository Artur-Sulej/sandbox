defmodule SandboxWeb.AccountBalanceControllerTest do
  use SandboxWeb.ConnCase
  import Hammox
  setup :verify_on_exit!

  @account_id "acc_1"

  setup %{conn: conn} do
    conn = put_req_header(conn, "authorization", "Basic dGVzdF93YXp6dXA6")
    {:ok, conn: conn}
  end

  describe "show" do
    test "fetch the account balance", %{conn: conn} do
      expect(
        Sandbox.LedgerBehaviour.impl(),
        :get_account_balance,
        fn args ->
          assert args.token == "test_wazzup"
          assert args.base_url =~ "http"

          {:ok, build_account_balance()}
        end
      )

      conn = get(conn, Routes.account_account_balance_path(conn, :show, @account_id))
      response_account_balance = json_response(conn, 200)
      response_keys = response_account_balance |> Map.keys() |> Enum.sort()

      assert response_keys == expected_keys()
    end

    test "error if not found", %{conn: conn} do
      stub(
        Sandbox.LedgerBehaviour.impl(),
        :get_account_balance,
        fn _args -> {:error, :not_found} end
      )

      conn = get(conn, Routes.account_account_balance_path(conn, :show, @account_id))
      json_response(conn, 404)
    end
  end

  defp expected_keys do
    build_account_balance() |> Map.keys() |> Enum.map(&Atom.to_string/1) |> Enum.sort()
  end

  defp build_account_balance do
    %{
      account_id: "account_id",
      available: "available",
      ledger: "ledger",
      links: %{
        account: "account",
        self: "self"
      }
    }
  end
end
