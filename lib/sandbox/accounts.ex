defmodule Sandbox.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias Sandbox.AccountBuilder

  @doc """
  Returns a list of accounts.
  """
  def list_accounts(token) do
    AccountBuilder.list_accounts(token)
  end

  @doc """
  Returns a single account for a given id.
  """
  def get_account(token, id) do
    AccountBuilder.get_account(token, id)
  end

  @doc """
  Returns a list of transactions for a given account.
  """
  def list_transactions(token, account_id) do
    if AccountBuilder.get_account(token, account_id) do
      id =
        :crypto.hash(:md5, "#{token}trx#{1}")
        |> Base.encode16()
        |> String.slice(0..20)
        |> String.downcase()
        |> (&"trx_#{&1}").()

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
          type: "withdrawal"
        }
      ]
    else
      []
    end
  end

  @doc """
  Returns a single transaction.
  """
  def get_transaction(token, account_id, id) do
    token
    |> list_transactions(account_id)
    |> Enum.find(fn trx -> trx.id == id end)
  end
end
