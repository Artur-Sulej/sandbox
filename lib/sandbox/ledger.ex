defmodule Sandbox.Ledger do
  @moduledoc """
  The Ledger context.
  """

  alias Sandbox.Ledger.AccountBuilder
  alias Sandbox.Ledger.TransactionBuilder

  @doc """
  Returns a list of accounts.
  """
  def list_accounts(token, base_url) do
    AccountBuilder.list_accounts(token, base_url)
  end

  @doc """
  Returns a single account for a given id.
  """
  def get_account(token, id, base_url) do
    AccountBuilder.get_account(token, id, base_url)
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
