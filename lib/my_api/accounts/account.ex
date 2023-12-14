defmodule MyApi.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @optional_fields [:id, :inserted_at, :updated_at]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :email, :string
    field :hash_password, :string
    has_one :user, MyApi.Users.User

    timestamps(type: :utc_datetime)
  end

  defp all_fields do
    __MODULE__.__schema__(:fields)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, all_fields())
    |> validate_required(all_fields() -- @optional_fields)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have @ and no spaces")
    |> validate_length(:email, max: 160)
    |> unique_constraint(:email)
    # hash the password when creating an account
    |> put_password_hash()
  end

  # This method will hash the password passed by the user
  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{hash_password: hash_password}} = changeset
       ) do
    change(changeset, hash_password: Bcrypt.hash_pwd_salt(hash_password))
  end

  defp put_password_hash(changeset), do: changeset
end
