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
  def list_transactions(opts) do
    TransactionBuilder.list_transactions(opts)
  end

  @doc """
  Returns a single transaction.
  """
  def get_transaction(opts) do
    TransactionBuilder.get_transaction(opts)
  end
end
