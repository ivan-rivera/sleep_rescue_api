defmodule SleepRescue.Users.IsiTest do

  use SleepRescue.DataCase
  alias SleepRescue.Repo
  alias SleepRescue.Users.{User, Isi}
  alias SleepRescue.Test.Support.Defaults

  @now DateTime.utc_now |> DateTime.truncate(:second)
  @user %{
    email: "user@mail.com",
    password: "secret123",
    password_confirmation: "secret123"
  }
  @user2 %{
    email: "user2@mail.com",
    password: "secret123",
    password_confirmation: "secret123"
  }

  setup do
    user = %User{}
           |> User.changeset(@user)
           |> Ecto.Changeset.change(%{email_confirmed_at: @now})
           |> Repo.insert!()
    user2 = %User{}
           |> User.changeset(@user2)
           |> Ecto.Changeset.change(%{email_confirmed_at: @now})
           |> Repo.insert!()
    %{user: user, user2: user2}
  end

  describe "changeset/2" do
    test "valid changeset" do
      assert %{valid?: true} = Isi.changeset(%Isi{}, Defaults.get_valid_isi)
    end
    test "invalid changeset" do
      assert %{valid?: false} = Isi.changeset(%Isi{}, Defaults.get_invalid_isi)
    end
  end

  describe "create_or_update/2" do
    test "create a valid ISI result", %{user: user} do
      assert {:ok, %Isi{}} = Isi.create_or_update_isi(user, Defaults.get_valid_isi)
    end
    test "update a valid ISI result", %{user: user} do
      update_attrs = Map.put(Defaults.get_valid_isi, "worried", 4)
      assert {:ok, %Isi{}} = Isi.create_or_update_isi(user, Defaults.get_valid_isi)
      assert {:ok, %Isi{}} = Isi.create_or_update_isi(user, update_attrs)
    end
  end

  describe "delete/2" do
    test "delete an ISI result", %{user: user} do
      {:ok, %{id: id}} = Isi.create_or_update_isi(user, Defaults.get_valid_isi)
      assert {:ok, _} = Isi.delete_isi(user, id)
    end
    test "delete an ISI result owned by another user", %{user: user, user2: user2} do
      {:ok, %{id: _}} = Isi.create_or_update_isi(user, Defaults.get_valid_isi)
      {:ok, %{id: id}} = Isi.create_or_update_isi(user2, Defaults.get_valid_isi)
      assert {:error, _} = Isi.delete_isi(user, id)
    end
  end

  describe "list_isis/2" do
    test "list ISI results when no records exist", %{user: user} do
      assert {:ok, []} = Isi.list_isis(user)
    end
    test "list ISI results with records", %{user: user} do
      Isi.create_or_update_isi(user, Defaults.get_valid_isi)
      assert {:ok, [%Isi{}]} = Isi.list_isis(user)
    end
    test "list limited ISI results", %{user: user} do
      user
      |> Ecto.build_assoc(:isis)
      |> Isi.changeset(Defaults.get_valid_isi, ~D[2021-01-01])
      |> Repo.insert()
      user
      |> Ecto.build_assoc(:isis)
      |> Isi.changeset(Defaults.get_valid_isi, ~D[2021-01-02])
      |> Repo.insert()
      assert {:ok, [%Isi{date: ~D[2021-01-02]}]} = Isi.list_isis(user, 1)
    end
  end

end
