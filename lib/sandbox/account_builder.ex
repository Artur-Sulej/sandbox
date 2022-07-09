defmodule Sandbox.AccountBuilder do
  def list_accounts(token) do
    accounts_count =
      token
      |> :crypto.bytes_to_integer()
      |> rem(4)
      |> Kernel.+(1)

    1..accounts_count
    |> Enum.map(fn index ->
      id =
        :crypto.hash(:md5, "#{token}#{index}")
        |> Base.encode16()
        |> String.slice(0..20)
        |> String.downcase()

      "acc_#{id}"
    end)
    |> Enum.map(&build_account/1)
  end

  def get_account(token, id) do
    token
    |> list_accounts()
    |> Enum.find(fn account -> account.id == id end)
  end

  defp build_account(id) do
    %{
      currency: "USD",
      enrollment_id: "enr_o3oveb8h0pukpk616a000",
      id: id,
      institution: institution(id),
      last_four: "5765",
      links: %{
        balances: "https://api.teller.io/accounts/#{id}/balances",
        self: "https://api.teller.io/accounts/#{id}",
        transactions: "https://api.teller.io/accounts/#{id}/transactions"
      },
      name: "Platinum Card",
      status: "open",
      subtype: "credit_card",
      type: "credit"
    }
  end

  defp institution(token) do
    seed_random(token)

    institution_name =
      Enum.random(["Chase", "Bank of America", "Wells Fargo", "Citibank", "Capital One"])

    institution_id =
      institution_name
      |> String.replace(" ", "_")
      |> String.downcase()

    %{
      id: institution_id,
      name: institution_name
    }
  end

  defp seed_random(seed) do
    seed_int = :crypto.bytes_to_integer(seed)
    :rand.seed(:exsplus, {seed_int, seed_int, seed_int})
  end
end
