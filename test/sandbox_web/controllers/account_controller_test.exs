defmodule SandboxWeb.AccountControllerTest do
  use SandboxWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all accounts", %{conn: conn} do
      conn = get(conn, Routes.account_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "show" do
    test "fetch the account", %{conn: conn} do
      conn = get(conn, Routes.account_path(conn, :show, 123))
      assert json_response(conn, 200)["data"] == nil
    end
  end
end
