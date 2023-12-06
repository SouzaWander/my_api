defmodule MyApiWeb.Auth.SetAccount do
  import Plug.Conn
  alias MyApiWeb.Auth.ErrorResponse
  alias MyApi.Accounts
  # This functions make part of the Plug behaviour and are defined in plug.ex
  def init(_options) do
  end

  def call(conn, _options) do
    if conn.assigns[:account] do
      conn
    else
      account_id = get_session(conn, :account_id)

      if account_id == nil, do: raise(ErrorResponse.Unauthorized)

      account = Accounts.get_full_account(account_id)

      cond do
        account_id && account -> assign(conn, :account, account)
        true -> assign(conn, :account, nil)
      end
    end
  end
end
