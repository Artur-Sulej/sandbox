defmodule SandboxWeb.TransactionControllerTest do
  use SandboxWeb.ConnCase
  import Hammox
  setup :verify_on_exit!

  @account_id "acc_1"
  @transaction_id "txn_1"

  setup %{conn: conn} do
    conn = put_req_header(conn, "authorization", "Basic dGVzdF93YXp6dXA6")
    {:ok, conn: conn}
  end

  describe "index" do
    test "lists all transactions", %{conn: conn} do
      expect(
        Sandbox.LedgerBehaviour.impl(),
        :list_transactions,
        fn args ->
          assert args[:token] == "test_wazzup"
          assert args[:account_id] == @account_id
          assert args[:base_url] =~ "http"
          assert is_nil(args[:from_id])
          assert is_nil(args[:transactions_count])

          [build_transaction()]
        end
      )

      conn = get(conn, Routes.account_transaction_path(conn, :index, @account_id))
      [response_transaction] = json_response(conn, 200)
      response_keys = response_transaction |> Map.keys() |> Enum.sort()

      assert response_keys == expected_keys()
    end

    test "lists paginated transactions", %{conn: conn} do
      expect(
        Sandbox.LedgerBehaviour.impl(),
        :list_transactions,
        fn args ->
          assert args[:token] == "test_wazzup"
          assert args[:account_id] == @account_id
          assert args[:base_url] =~ "http"
          assert args[:from_id] == "txn_2"
          assert args[:transactions_count] == 5

          [build_transaction()]
        end
      )

      params = [from_id: "txn_2", count: "5"]
      conn = get(conn, Routes.account_transaction_path(conn, :index, @account_id), params)
      [response_transaction] = json_response(conn, 200)
      response_keys = response_transaction |> Map.keys() |> Enum.sort()

      assert response_keys == expected_keys()
    end

    test "error for incorrect params", %{conn: conn} do
      stub(
        Sandbox.LedgerBehaviour.impl(),
        :list_transactions,
        fn _args ->
          raise "Should not be called"
        end
      )

      params = [count: "wrong"]
      conn = get(conn, Routes.account_transaction_path(conn, :index, @account_id), params)
      json_response(conn, 400)
    end
  end

  describe "show" do
    test "fetch the transaction", %{conn: conn} do
      expect(
        Sandbox.LedgerBehaviour.impl(),
        :get_transaction,
        fn args ->
          assert args.token == "test_wazzup"
          assert args.base_url =~ "http"
          assert args.id == @transaction_id

          build_transaction()
        end
      )

      conn = get(conn, Routes.account_transaction_path(conn, :show, @account_id, @transaction_id))
      response_transaction = json_response(conn, 200)
      response_keys = response_transaction |> Map.keys() |> Enum.sort()

      assert response_keys == expected_keys()
    end
  end

  defp expected_keys do
    build_transaction() |> Map.keys() |> Enum.map(&Atom.to_string/1) |> Enum.sort()
  end

  defp build_transaction do
    %{
      id: "id",
      account_id: "account_id",
      amount: "amount",
      date: "date",
      description: "description",
      details: %{
        category: "category",
        counterparty: %{
          name: "name",
          type: "type"
        },
        processing_status: "processing_status"
      },
      links: %{
        account: "account",
        self: "self"
      },
      running_balance: "running_balance",
      status: "status",
      type: "type"
    }
  end
end
