defmodule MyApi.Schema.AccountTest do
  use MyApi.Support.SchemaCase
  alias MyApi.Accounts.Account

  @expected_field_types [
    {:id, :binary_id},
    {:email, :string},
    {:hash_password, :string},
    {:inserted_at, :utc_datetime},
    {:updated_at, :utc_datetime}
  ]

  @optional [:id, :inserted_at, :updated_at]

  describe "fields and types" do
    test "it has the correct fields and types" do
      actual_fields_with_types =
        for field <- Account.__schema__(:fields) do
          type = Account.__schema__(:type, field)
          {field, type}
        end

      assert MapSet.new(actual_fields_with_types) == MapSet.new(@expected_field_types)
    end
  end

  describe "changeset/2" do
    test "success: returns a valid changeset when given valid arguments" do
      valid_params = valid_params(@expected_field_types)

      changeset = Account.changeset(%Account{}, valid_params)

      assert %Changeset{valid?: true, changes: changes} = changeset
      mutated = [:hash_password]

      for {field, _} <- @expected_field_types, field not in mutated do
        actual = Map.get(changes, field)
        expected = valid_params[Atom.to_string(field)]

        assert actual == expected,
               "Values did not match for field: #{field}\nexpected: #{inspect(expected)}\nactual: #{inspect(actual)}"
      end

      assert Bcrypt.verify_pass(valid_params["hash_password"], changes.hash_password),
             "Password: #{inspect(valid_params["hash_password"])} does not match \nhash: #{inspect(changes.hash_password)}"
    end

    test "error: returns an error changeset when given un-castable values" do
      invalid_params = invalid_params(@expected_field_types)

      assert %Changeset{valid?: false, errors: errors} =
               Account.changeset(%Account{}, invalid_params)

      for {field, _} <- @expected_field_types do
        assert errors[field], "The field #{field} is missing from errors."

        {_, meta} = errors[field]

        assert meta[:validation] == :cast,
               "The validation type, #{meta[:validation]}, is incorrect."
      end
    end

    test "error: returns an error changeset when required fields are missing" do
      params = %{}

      assert %Changeset{valid?: false, errors: errors} =
               Account.changeset(%Account{}, params)

      for {field, _} <- @expected_field_types, field not in @optional do
        assert errors[field], "The field #{field} is missing from errors."

        {_, meta} = errors[field]

        assert meta[:validation] == :required,
               "The validation type, #{meta[:validation]}, is incorrect."
      end

      for field <- @optional do
        refute errors[field], "The optional field is required when it shouldn't be"
      end
    end

    test "error: returns an error changeset when an email address is reused" do
      Ecto.Adapters.SQL.Sandbox.checkout(MyApi.Repo)

      {:ok, existing_account} =
        %Account{}
        |> Account.changeset(valid_params(@expected_field_types))
        |> MyApi.Repo.insert()

      changeset_with_repeated_email =
        %Account{}
        |> Account.changeset(
          valid_params(@expected_field_types)
          |> Map.put("email", existing_account.email)
        )

      assert {:error, %Changeset{valid?: false, errors: errors}} =
               MyApi.Repo.insert(changeset_with_repeated_email)

      assert errors[:email], "The field :email is missing from errors."

      {_, meta} = errors[:email]

      assert meta[:constraint] == :unique,
             "The validation type, #{meta[:validation]}, is incorrect."
    end
  end
end
