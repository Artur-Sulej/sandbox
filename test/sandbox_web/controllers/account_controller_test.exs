defmodule SandboxWeb.AccountControllerTest do
  use SandboxWeb.ConnCase

  setup %{conn: conn} do
    conn = put_req_header(conn, "authorization", "Basic dGVzdF93YXp6dXA6")
    {:ok, conn: conn}
  end

  describe "index" do
    test "lists all accounts", %{conn: conn} do
      conn = get(conn, Routes.account_path(conn, :index))

      assert [
               %{"id" => "acc_4d5d38b527402c061bc0d"}
             ] = json_response(conn, 200)
    end
  end

  describe "show" do
    test "fetch the account", %{conn: conn} do
      conn = get(conn, Routes.account_path(conn, :show, "acc_4d5d38b527402c061bc0d"))
      assert %{"id" => "acc_4d5d38b527402c061bc0d"} = json_response(conn, 200)
    end
  end
end
