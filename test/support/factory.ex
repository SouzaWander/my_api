defmodule MyApi.Support.Factory do
  alias MyApi.Accounts.Account
  use ExMachina.Ecto, repo: MyApi.Repo

  def account_factory do
    %Account{
      email: Faker.Internet.email(),
      hash_password: Faker.Internet.slug()
    }
  end
end
