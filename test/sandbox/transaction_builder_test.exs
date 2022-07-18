defmodule Sandbox.TransactionBuilderTest do
  use ExUnit.Case

  alias Sandbox.Ledger.TransactionBuilder

  @token1 "test_one"
  @token2 "test_two"
  @account_id1 "acc_2776d00ed47e1bdd82f24"
  @account_id2 "acc_1a12637aded5310a22365"
  @from_date ~D[2022-07-15]
  @base_url Application.compile_env!(:sandbox, :base_url)

  describe "list_transactions/2" do
    test "returns all transactions for given account" do
      transactions1 =
        TransactionBuilder.list_transactions(%{
          token: @token1,
          account_id: @account_id1,
          base_url: @base_url
        })

      transactions2 =
        TransactionBuilder.list_transactions(%{
          token: @token2,
          account_id: @account_id1,
          base_url: @base_url
        })

      assert Enum.any?(transactions1)
      assert Enum.empty?(transactions2)

      Enum.each(transactions1, fn txn ->
        assert %{
                 account_id: @account_id1,
                 amount: _,
                 date: _,
                 description: _,
                 details: %{
                   category: "service",
                   counterparty: %{name: "BANK OF THE WEST", type: "organization"},
                   processing_status: "complete"
                 },
                 id: _,
                 links: %{
                   account: _,
                   self: _
                 },
                 running_balance: _,
                 status: "pending",
                 type: "card_payment"
               } = txn
      end)
    end

    test "returns transactions for last 90 days" do
      transactions =
        TransactionBuilder.list_transactions(%{
          token: @token1,
          account_id: @account_id1,
          base_url: @base_url
        })

      first_txn = List.first(transactions)
      last_txn = List.last(transactions)

      end_date = Date.utc_today()
      start_date = Date.add(end_date, -89)

      end_date_comparison = Date.compare(end_date, Date.from_iso8601!(first_txn.date))
      start_date_comparison = Date.compare(start_date, Date.from_iso8601!(last_txn.date))

      assert transactions == Enum.sort_by(transactions, & &1.date, &>=/2)
      assert end_date_comparison in [:gt, :eq]
      assert start_date_comparison in [:lt, :eq]
    end

    test "moving time window doesn't change transactions for same days" do
      from_date1 = ~D[2022-04-26]
      from_date2 = ~D[2022-07-14]

      transactions1 =
        TransactionBuilder.list_transactions(%{
          token: @token1,
          account_id: @account_id1,
          base_url: @base_url,
          from_date: from_date1
        })

      transactions2 =
        TransactionBuilder.list_transactions(%{
          token: @token1,
          account_id: @account_id1,
          base_url: @base_url,
          from_date: from_date2
        })

      helper_list = transactions1 -- transactions2
      txn_intersection = Enum.sort_by(transactions1 -- helper_list, & &1.date, &>=/2)

      first_txn = List.first(txn_intersection)
      last_txn = List.last(txn_intersection)

      assert {first_txn.date, last_txn.date} == {"2022-04-26", "2022-04-16"}
    end

    test "returns constant transactions and different for two accounts" do
      transactions1a =
        TransactionBuilder.list_transactions(%{
          token: @token1,
          account_id: @account_id1,
          base_url: @base_url
        })

      transactions1b =
        TransactionBuilder.list_transactions(%{
          token: @token1,
          account_id: @account_id1,
          base_url: @base_url
        })

      transactions2a =
        TransactionBuilder.list_transactions(%{
          token: @token2,
          account_id: @account_id2,
          base_url: @base_url
        })

      transactions2b =
        TransactionBuilder.list_transactions(%{
          token: @token2,
          account_id: @account_id2,
          base_url: @base_url
        })

      assert Enum.any?(transactions1a)
      assert Enum.any?(transactions1b)
      assert Enum.any?(transactions2a)
      assert Enum.any?(transactions2b)
      assert transactions1a == transactions1b
      assert transactions2a == transactions2b
      assert transactions2a != transactions1a
    end

    test "limiting transactions with count param" do
      count = 4

      txn_all =
        TransactionBuilder.list_transactions(%{
          token: @token1,
          account_id: @account_id1,
          base_url: @base_url,
          from_date: @from_date
        })

      txn_with_count =
        TransactionBuilder.list_transactions(%{
          token: @token1,
          account_id: @account_id1,
          base_url: @base_url,
          from_date: @from_date,
          transactions_count: count
        })

      assert count == Enum.count(txn_with_count)
      assert txn_with_count == Enum.take(txn_all, count)
    end

    test "paginating transactions with id and count" do
      count = 2

      txn_all =
        TransactionBuilder.list_transactions(%{
          token: @token1,
          account_id: @account_id1,
          base_url: @base_url,
          from_date: @from_date
        })

      [_, %{id: from_id}, txn_1, txn_2 | _tail] = txn_all

      txn_with_count_from_id =
        TransactionBuilder.list_transactions(%{
          token: @token1,
          account_id: @account_id1,
          base_url: @base_url,
          from_date: @from_date,
          transactions_count: count,
          from_id: from_id
        })

      assert count == Enum.count(txn_with_count_from_id)
      assert [^txn_1, ^txn_2] = txn_with_count_from_id
    end

    test "transactions have a running balance" do
      txn =
        TransactionBuilder.list_transactions(%{
          token: @token2,
          account_id: @account_id2,
          base_url: @base_url,
          from_date: @from_date,
          transactions_count: 3
        })

      [
        %{amount: amount_string3, running_balance: running_balance_string3},
        %{amount: amount_string2, running_balance: running_balance_string2},
        %{amount: amount_string1, running_balance: running_balance_string1}
      ] = txn

      {amount1, ""} = Float.parse(amount_string1)
      {amount2, ""} = Float.parse(amount_string2)
      {amount3, ""} = Float.parse(amount_string3)
      {running_balance1, ""} = Float.parse(running_balance_string1)
      {running_balance2, ""} = Float.parse(running_balance_string2)
      {running_balance3, ""} = Float.parse(running_balance_string3)

      assert amount1 < 0
      assert amount2 < 0
      assert amount3 < 0
      assert Float.round(running_balance1 + amount2, 2) == running_balance2
      assert Float.round(running_balance2 + amount3, 2) == running_balance3
    end
  end

  describe "get_transaction/3" do
    test "returns transaction only for correct token and ids" do
      txn_id = "txn_1331cd70a7120add9637d"

      assert TransactionBuilder.get_transaction(%{
               token: @token1,
               account_id: @account_id1,
               base_url: @base_url,
               id: txn_id,
               from_date: @from_date
             }) ==
               build_transaction(%{
                 id: txn_id,
                 date: "2022-06-30",
                 amount: "-29.99",
                 running_balance: "91040.97",
                 description: "Jack In The Box",
                 account_id: @account_id1
               })

      refute TransactionBuilder.get_transaction(%{
               token: "other_token",
               account_id: @account_id1,
               base_url: @base_url,
               id: txn_id,
               from_date: @from_date
             })

      refute TransactionBuilder.get_transaction(%{
               token: @token1,
               account_id: "other_account",
               base_url: @base_url,
               id: txn_id,
               from_date: @from_date
             })

      refute TransactionBuilder.get_transaction(%{
               token: @token1,
               account_id: @account_id1,
               base_url: @base_url,
               id: "other_txn",
               from_date: @from_date
             })
    end

    test "listed transaction accessible via get_transaction/3" do
      transactions1 =
        TransactionBuilder.list_transactions(%{
          token: @token1,
          account_id: @account_id1,
          base_url: @base_url,
          from_date: @from_date
        })

      transactions2 =
        TransactionBuilder.list_transactions(%{
          token: @token2,
          account_id: @account_id2,
          base_url: @base_url,
          from_date: @from_date
        })

      assert Enum.any?(transactions1)
      assert Enum.any?(transactions2)

      Enum.each(transactions1, fn transaction ->
        assert TransactionBuilder.get_transaction(%{
                 token: @token1,
                 account_id: @account_id1,
                 base_url: @base_url,
                 id: transaction.id,
                 from_date: @from_date
               })

        refute TransactionBuilder.get_transaction(%{
                 token: @token2,
                 account_id: @account_id2,
                 base_url: @base_url,
                 id: transaction.id,
                 from_date: @from_date
               })
      end)

      Enum.each(transactions2, fn transaction ->
        refute TransactionBuilder.get_transaction(%{
                 token: @token1,
                 account_id: @account_id1,
                 base_url: @base_url,
                 id: transaction.id,
                 from_date: @from_date
               })

        assert TransactionBuilder.get_transaction(%{
                 token: @token2,
                 account_id: @account_id2,
                 base_url: @base_url,
                 id: transaction.id,
                 from_date: @from_date
               })
      end)
    end

    defp build_transaction(%{
           id: txn_id,
           date: date,
           amount: amount,
           running_balance: running_balance,
           description: description,
           account_id: account_id
         }) do
      %{
        account_id: account_id,
        amount: amount,
        date: date,
        description: description,
        details: %{
          category: "service",
          counterparty: %{
            name: "BANK OF THE WEST",
            type: "organization"
          },
          processing_status: "complete"
        },
        id: txn_id,
        links: %{
          account: "https://api.example.com/accounts/#{account_id}",
          self: "https://api.example.com/accounts/#{account_id}/transactions/#{txn_id}"
        },
        running_balance: running_balance,
        status: "pending",
        type: "card_payment"
      }
    end
  end
end
