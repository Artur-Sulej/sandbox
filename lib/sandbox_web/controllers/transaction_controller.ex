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

  defp add_additional_data(params, conn) do
    data = %{
      token: conn.assigns.token,
      base_url: SandboxWeb.Endpoint.url()
    }

    Map.merge(params, data)
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

  defp parse_params(params, properties) do
    parsed_params =
      Enum.reduce(properties, %{}, fn {key, type, required}, acc ->
        parsed_param = parse_param(params[key], type, required)
        Map.put(acc, String.to_atom(key), parsed_param)
      end)

    any_error? =
      Enum.any?(Map.values(parsed_params), fn
        :error -> true
        _ -> false
      end)

    if any_error? do
      {:error, :invalid_params}
    else
      {:ok, parsed_params}
    end
  end

  defp parse_param(param, type, required) do
    case {param, type, required} do
      {nil, _, true} -> :error
      {"", _, true} -> :error
      {nil, _, _} -> nil
      {"", _, _} -> nil
      {param, :positive_integer, _} -> parse_positive_integer(param)
      {param, :string, _} -> param
    end
  end

  defp parse_positive_integer(param) do
    case Integer.parse(param) do
      :error -> :error
      {int_param, ""} when int_param > 0 -> int_param
      _ -> :error
    end
  end

  defp rename_key(map, old_key, new_key) do
    Map.new(map, fn
      {^old_key, count} -> {new_key, count}
      pair -> pair
    end)
  end
end
