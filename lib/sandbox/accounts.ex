defmodule Sandbox.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias Sandbox.Accounts.AccountBuilder
  alias Sandbox.Accounts.TransactionBuilder

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
    TransactionBuilder.list_transactions(token, account_id)
  end

  @doc """
  Returns a single transaction.
  """
  def get_transaction(token, account_id, id) do
    TransactionBuilder.get_transaction(token, account_id, id)
  end
end
