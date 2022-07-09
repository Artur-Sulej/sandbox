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
end
