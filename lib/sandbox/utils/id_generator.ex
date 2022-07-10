defmodule Sandbox.Utils.IdGenerator do
  @length 21

  def generate_id(token, prefix, index) do
    :crypto.hash(:md5, "#{token}#{prefix}#{index}")
    |> Base.encode16()
    |> String.slice(0..(@length - 1))
    |> String.downcase()
    |> (&"#{prefix}_#{&1}").()
  end
end
