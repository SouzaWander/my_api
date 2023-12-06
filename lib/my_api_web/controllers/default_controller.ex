defmodule MyApiWeb.DefaultController do
  use MyApiWeb, :controller

  def index(conn, _params) do
    text(conn, "MyApi is LIVE - #{Mix.env()}")
  end
end
