defmodule MyApi.Support.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias MyApi.{Support.Factory, Repo}
      alias Ecto.Changeset
    end
  end

  setup _ do
    Ecto.Adapters.SQL.Sandbox.mode(MyApi.Repo, :manual)
  end
end
