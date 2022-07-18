defmodule Sandbox.Ledger do
  @moduledoc """
  The Ledger context.
  """

  @behaviour Sandbox.LedgerBehaviour

  alias Sandbox.Ledger.AccountBuilder
  alias Sandbox.Ledger.TransactionBuilder

  @doc """
  Returns a list of accounts.
  """
  @impl true
  def list_accounts(token, base_url) do
    AccountBuilder.list_accounts(token, base_url)
  end

  @doc """
  Returns a single account for a given id.
  """
  @impl true
  def get_account(token, id, base_url) do
    AccountBuilder.get_account(token, id, base_url)
  end

  @doc """
  Returns a list of transactions for a given account.
  """
  @impl true
  def list_transactions(args) do
    TransactionBuilder.list_transactions(args)
  end

  @doc """
  Returns a single transaction.
  """
  @impl true
  def get_transaction(args) do
    TransactionBuilder.get_transaction(args)
  end
end
