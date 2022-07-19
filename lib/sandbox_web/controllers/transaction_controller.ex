defmodule SandboxWeb.TransactionController do
  use SandboxWeb, :controller

  alias Sandbox.LedgerBehaviour

  action_fallback SandboxWeb.FallbackController

  def index(conn, params) do
    with {:ok, parsed_params} <- parse_index_params(params),
         parsed_params <- add_additional_data(parsed_params, conn),
         {:ok, transactions} <- LedgerBehaviour.impl().list_transactions(parsed_params) do
      render(conn, "index.json", transactions: transactions)
    else
      {:error, :not_found} -> {:error, :not_found}
      {:error, _} -> {:error, :bad_request}
    end
  end

  def show(conn, params) do
    with {:ok, parsed_params} <- parse_show_params(params),
         parsed_params <- add_additional_data(parsed_params, conn),
         {:ok, transaction} <- LedgerBehaviour.impl().get_transaction(parsed_params) do
      render(conn, "show.json", transaction: transaction)
    else
      {:error, :not_found} -> {:error, :not_found}
      {:error, _} -> {:error, :bad_request}
    end
  end

  defp parse_index_params(params) do
    properties = [
      {"account_id", :string, true},
      {"from_id", :string, false},
      {"count", :positive_integer, false}
    ]

    case parse_params(params, properties) do
      {:ok, parsed_params} ->
        new_params = rename_key(parsed_params, :count, :transactions_count)
        {:ok, new_params}

      result ->
        result
    end
  end

  defp parse_show_params(params) do
    properties = [
      {"account_id", :string, true},
      {"id", :string, true}
    ]

    parse_params(params, properties)
  end
end
