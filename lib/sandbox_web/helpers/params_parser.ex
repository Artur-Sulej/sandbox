defmodule SandboxWeb.Helpers.ParamsParser do
  @moduledoc false

  def add_additional_data(params, conn) do
    data = %{
      token: conn.assigns.token,
      base_url: SandboxWeb.Endpoint.url()
    }

    Map.merge(params, data)
  end

  def parse_params(params, properties) do
    parsed_params =
      Enum.reduce(properties, %{}, fn {key, type, required}, acc ->
        parsed_param = parse_param(params[key], type, required)
        Map.put(acc, String.to_atom(key), parsed_param)
      end)

    any_error? =
      Enum.any?(Map.values(parsed_params), fn
        :error -> true
        _ -> false
      end)

    if any_error? do
      {:error, :invalid_params}
    else
      {:ok, parsed_params}
    end
  end

  def parse_param(param, type, required) do
    case {param, type, required} do
      {nil, _, true} -> :error
      {"", _, true} -> :error
      {nil, _, _} -> nil
      {"", _, _} -> nil
      {param, :positive_integer, _} -> parse_positive_integer(param)
      {param, :string, _} -> param
    end
  end

  def parse_positive_integer(param) do
    case Integer.parse(param) do
      :error -> :error
      {int_param, ""} when int_param > 0 -> int_param
      _ -> :error
    end
  end

  def rename_key(map, old_key, new_key) do
    Map.new(map, fn
      {^old_key, count} -> {new_key, count}
      pair -> pair
    end)
  end
end
