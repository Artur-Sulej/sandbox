defmodule Sandbox.Accounts.TransactionBuilder do
  alias Sandbox.Accounts.AccountBuilder
  alias Sandbox.Utils.IdGenerator

  def list_transactions(token, account_id) do
    if AccountBuilder.get_account(token, account_id) do
      id = IdGenerator.generate_id(token, "trx", 1)

      [
        %{
          account_id: account_id,
          amount: "-84.88",
          date: "2022-07-10",
          description: "Electronic Withdrawal",
          details: %{
            category: "service",
            counterparty: %{
              name: "BANK OF THE WEST",
              type: "organization"
            },
            processing_status: "complete"
          },
          id: id,
          links: %{
            account: "https://api.teller.io/accounts/#{account_id}",
            self: "https://api.teller.io/accounts/#{account_id}/transactions/#{id}"
          },
          running_balance: nil,
          status: "pending",
          type: "card_payment"
        }
      ]
    else
      []
    end
  end

  def get_transaction(token, account_id, trx_id) do
    token
    |> list_transactions(account_id)
    |> Enum.find(fn %{id: id} -> id == trx_id end)
  end
end
