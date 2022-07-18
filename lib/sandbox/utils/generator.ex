defmodule Sandbox.Utils.Generator do
  @id_length 21

  def generate_id(string, prefix) do
    :crypto.hash(:md5, "#{prefix}#{string}")
    |> Base.encode16()
    |> String.slice(0..(@id_length - 1))
    |> String.downcase()
    |> (&"#{prefix}_#{&1}").()
  end

  def generate_integer(string, max) do
    :crypto.hash(:md5, string)
    |> :crypto.bytes_to_integer()
    |> rem(max + 1)
  end

  def random_item(list, seed) do
    seed_int =
      :crypto.hash(:md5, seed)
      |> :crypto.bytes_to_integer()

    :rand.seed(:exsplus, {seed_int, seed_int, seed_int})
    Enum.random(list)
  end
end
