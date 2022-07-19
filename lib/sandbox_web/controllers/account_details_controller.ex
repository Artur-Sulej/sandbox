defmodule SandboxWeb.AccountDetailController do
  use SandboxWeb, :controller

  alias Sandbox.LedgerBehaviour

  action_fallback SandboxWeb.FallbackController

  def show(conn, params) do
    with {:ok, parsed_params} <- parse_show_params(params),
         parsed_params <- add_additional_data(parsed_params, conn),
         {:ok, account_details} <- LedgerBehaviour.impl().get_account_details(parsed_params) do
      render(conn, "show.json", account_detail: account_details)
    else
      {:error, :not_found} -> {:error, :not_found}
      {:error, _} -> {:error, :bad_request}
    end
  end

  defp parse_show_params(params) do
    properties = [
      {"account_id", :string, true}
    ]

    parse_params(params, properties)
  end
end
