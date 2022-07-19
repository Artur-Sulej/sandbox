defmodule Sandbox.GenerateToken do
  def call(["test_" <> main_part = token | _tail]) when byte_size(main_part) > 0 do
    token
    |> (&(&1 <> ":")).()
    |> Base.encode64()
    |> IO.puts()
  end

  def call(_) do
      IO.puts("Provide token prefixed with test_ as argument")
      IO.puts("Example usage: elixir generate_token.exs test_1234567")
  end
end

System.argv()
|> Sandbox.GenerateToken.call()
