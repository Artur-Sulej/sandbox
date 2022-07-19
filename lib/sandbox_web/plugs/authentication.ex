defmodule Sandbox.Plug.Authentication do
  @moduledoc """
  This plug parses auth header and assigns token.
  """
  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    with {token, _password} <- Plug.BasicAuth.parse_basic_auth(conn),
         true <- token_valid?(token) do
      assign(conn, :token, token)
    else
      _ -> send_resp(conn, 401, "")
    end
  end

  defp token_valid?("test_" <> token_tail) do
    case token_tail do
      "" -> false
      _ -> true
    end
  end

  defp token_valid?(_), do: false
end
