defmodule SandboxWeb.AccountControllerTest do
  use SandboxWeb.ConnCase
  import Hammox
  setup :verify_on_exit!

  @account_id "acc_1"

  setup %{conn: conn} do
    conn = put_req_header(conn, "authorization", "Basic dGVzdF93YXp6dXA6")
    {:ok, conn: conn}
  end

  describe "index" do
    test "lists all accounts", %{conn: conn} do
      expect(
        Sandbox.LedgerBehaviour.impl(),
        :list_accounts,
        fn token, base_url ->
          assert token == "test_wazzup"
          assert base_url =~ "http"

          {:ok, [build_account()]}
        end
      )

      conn = get(conn, Routes.account_path(conn, :index))
      [response_account] = json_response(conn, 200)
      response_keys = response_account |> Map.keys() |> Enum.sort()

      assert response_keys == expected_keys()
    end
  end

  describe "show" do
    test "fetch the account", %{conn: conn} do
      expect(
        Sandbox.LedgerBehaviour.impl(),
        :get_account,
        fn token, id, base_url ->
          assert token == "test_wazzup"
          assert base_url =~ "http"
          assert id == @account_id

          {:ok, build_account()}
        end
      )

      conn = get(conn, Routes.account_path(conn, :show, @account_id))
      response_account = json_response(conn, 200)
      response_keys = response_account |> Map.keys() |> Enum.sort()

      assert response_keys == expected_keys()
    end
  end

  defp expected_keys do
    build_account() |> Map.keys() |> Enum.map(&Atom.to_string/1) |> Enum.sort()
  end

  defp build_account do
    %{
      id: @account_id,
      currency: "currency",
      enrollment_id: "enrollment_id",
      institution: %{
        id: "id",
        name: "name"
      },
      last_four: "last_four",
      links: %{
        balances: "balances",
        self: "self",
        transactions: "transactions"
      },
      name: "name",
      status: "status",
      subtype: "subtype",
      type: "type"
    }
  end
end
