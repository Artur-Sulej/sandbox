defmodule Sandbox.LedgerBehaviour do
  @implementation Application.compile_env!(:sandbox, :ledger)
  def impl(), do: @implementation

  @type token :: String.t()
  @type base_url :: String.t()
  @type id :: String.t()

  @type list_transactions_args :: %{
          optional(:from_date) => Date.t(),
          token: token,
          account_id: id,
          base_url: base_url,
          from_id: id | nil,
          transactions_count: non_neg_integer() | nil
        }

  @type get_transaction_args :: %{
          optional(:from_date) => Date.t(),
          token: token,
          id: id,
          account_id: id,
          base_url: base_url
        }

  @type transaction :: %{
          id: id,
          account_id: id,
          amount: String.t(),
          date: String.t(),
          description: String.t(),
          details: %{
            category: String.t(),
            counterparty: %{
              name: String.t(),
              type: String.t()
            },
            processing_status: String.t()
          },
          links: %{
            account: String.t(),
            self: String.t()
          },
          running_balance: String.t(),
          status: String.t(),
          type: String.t()
        }

  @type account :: %{
          id: id,
          currency: String.t(),
          enrollment_id: String.t(),
          institution: %{
            id: String.t(),
            name: String.t()
          },
          last_four: String.t(),
          links: %{
            balances: String.t(),
            self: String.t(),
            transactions: String.t()
          },
          name: String.t(),
          status: String.t(),
          subtype: String.t(),
          type: String.t()
        }

  @callback list_accounts(token, base_url) :: [account]
  @callback get_account(token, id, base_url) :: account | nil
  @callback list_transactions(list_transactions_args) :: [transaction]
  @callback get_transaction(get_transaction_args) :: transaction | nil
end
